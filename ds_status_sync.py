"""ds_status_sync - sync DS-Connect status with KUMC REDCap

Integration Test Usage:

export DS_PASS=...
export DS_KEY=...
python ds_status_sync.py --get-status user123 DS_PASS DS_KEY

export REDCAP_API_TOKEN=...
python ds_status_sync.py --send-consent REDCAP_API_TOKEN

"""

import json
import logging
import typing as py
from datetime import datetime, timedelta
from pathlib import Path as Path_T
from urllib.error import HTTPError

from requests import Request, Session as Session_T

log = logging.getLogger(__name__)

REDCAP_API = 'https://redcap.kumc.edu/api/'

DS_DETERMINED = '92'

WebBuilder = py.Callable[..., Session_T]


def main(argv: py.List[str], env: py.Dict[str, str], stdout: py.IO[str],
         cwd: Path_T, now: py.Callable[[], datetime],
         make_session: WebBuilder) -> None:
    if '--get-status' in argv:
        [username, passkey, api_passkey] = argv[2:5]
        session = DSConnectStudy.basic_session(make_session,
                                               auth=(username, env[passkey]))
        ds = DSConnectStudy(session, api_key=env[api_passkey])
        ds._integration_test(stdout)
    elif '--send-consent' in argv:
        [api_passkey] = argv[2:3]
        svc = ConsentToLink(REDCAP_API, make_session(), env[api_passkey])
        svc._integration_test(cwd, now())
    else:
        raise ValueError(argv)


class REDCapAPI:
    def __init__(self, url: str,
                 session: Session_T, api_token: str) -> None:
        self.url = url
        self.__session = session
        self.__api_token = api_token

    def export_records(self, dateRangeBegin: datetime,
                       filterLogic: str,
                       fields_0: str) -> py.List[py.Dict[str, str]]:
        data = {
            'token': self.__api_token,
            'content': 'record',
            'format': 'json',
            'type': 'flat',
            'filterLogic': filterLogic,
            'fields[0]': fields_0,
            'returnFormat': 'json',
            'dateRangeBegin': self._fmt_time(dateRangeBegin),
        }
        log.info('export records: url=%s', self.url)
        log.debug('export records: data=%s', data)
        req = Request('POST', self.url, data=data)
        resp = self.__session.send(req.prepare())
        resp.raise_for_status()
        records = py.cast(py.List[py.Dict[str, str]], resp.json())
        log.debug('exported records: %s', records)
        return records

    @classmethod
    def _fmt_time(cls, when: datetime) -> str:
        """
        >>> REDCapAPI._fmt_time(datetime(2017, 1, 1))
        '2017-01-01 00:00:00'
        """
        return when.strftime('%Y-%m-%d %H:%M:%S')

    def export_pdf(self, instrument: str, record: str) -> py.IO[bytes]:
        req = Request('POST', self.url,
                      data={
                          'token': self.__api_token,
                          'content': 'pdf',
                          'record': record,
                          'instrument': instrument,
                          'returnFormat': 'json'
                      })
        resp = self.__session.send(req.prepare())
        resp.raise_for_status()
        return py.cast(py.IO[bytes], resp.raw)


class ConsentToLink(REDCapAPI):
    """REDCap API to get PDF consent form
    """

    instrument = 'consent_to_link'
    recent = timedelta(days=90)

    def consented_since(self, dateRangeBegin: datetime) -> py.List[str]:
        records = self.export_records(
            fields_0='record_id',
            filterLogic="[%s_complete] = '2'" % self.instrument,
            dateRangeBegin=dateRangeBegin)
        return [record['record_id'] for record in records]

    def consent_form(self, record: str) -> py.IO[bytes]:
        return self.export_pdf(self.instrument, record)

    def _integration_test(self, cwd: Path_T, now: datetime) -> None:
        try:
            for record in self.consented_since(now - self.recent):
                log.info('get consent form: record_id=%s', record)
                src = self.consent_form(record)
                dest = (cwd / record).with_suffix('.pdf')
                with dest.open('wb') as out:
                    content = src.read()
                    out.write(content)
                    log.info('saved %d bytes to %s', len(content), dest)
        except HTTPError as err:
            log.error('error %s %s\n%s\n%s',
                      err.code, err.reason, err.headers, err.read())
            raise


class DSConnectStudy:
    """DS-Connect API for a study
    """
    url = 'https://dsconnect25.pxrds-test.com/component/api/survey/getstatus'

    def __init__(self, session: Session_T, api_key: str) -> None:
        self.__session = session
        self.__api_key = api_key

    @classmethod
    def basic_session(cls, make_session: WebBuilder,
                      auth: py.Tuple[str, str]) -> Session_T:
        s = make_session()
        s.auth = auth
        return s

    def getstatus(self, stids: py.List[str]) -> py.List[object]:
        """get status of a survey: who made it how far?
        """
        req = Request('POST', self.url,
                      json={"stids": stids},
                      headers={
                          NoCap('Content-Type'): 'application/json',
                          NoCap('X-DSNIH-KEY'): self.__api_key,
                      })
        log.debug('getting status for %s:\ndata: %s\nheaders: %s',
                  stids, req.data, req.headers.items())
        s = self.__session
        resp = s.send(s.prepare_request(req))
        resp.raise_for_status()
        return [status for status in resp.json()]

    def send_user_consent(self, consent_do: bytes) -> None:
        raise NotImplementedError

    def _integration_test(self, stdout: py.IO[str]) -> None:
        try:
            status = self.getstatus([DS_DETERMINED])
            log.debug('status: %s', status)
            json.dump(status, stdout, indent=2)
        except HTTPError as err:
            log.error('error %s %s\n%s\n%s',
                      err.code, err.reason, err.headers, err.read())
            raise


class NoCap(str):
    """Work around HTTP header name case normalization

    The python standard library takes advantage of the case-insensitivity
    from the HTTP spec to normalize case of HTTP headers, but some
    servers (e.g. the DS-Connect API server) are sensitive to case anyway.

    So we override the capitalize() method used for case normalization.

    ack: Blender Aug '13 https://stackoverflow.com/a/18268226/7963
    """

    def title(self) -> str:
        return self

    def capitalize(self) -> str:
        return self


if __name__ == '__main__':
    def _script_io() -> None:
        from datetime import datetime
        from os import environ
        from pathlib import Path
        from sys import argv, stdout

        from requests import Session

        logging.basicConfig(level=logging.DEBUG)
        main(argv[:], env=environ.copy(), stdout=stdout,
             cwd=Path('.'), now=datetime.now,
             make_session=lambda: Session())

    _script_io()
