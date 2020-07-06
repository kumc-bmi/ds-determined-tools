"""ds_status_sync - sync DS-Connect status with KUMC REDCap

Integration Test Usage:

export DS_PASS=...
export DS_KEY=...
python ds_status_sync.py --get-status user123 DS_PASS DS_KEY

export REDCAP_API_TOKEN=...
python ds_status_sync.py --send-consent REDCAP_API_TOKEN

"""

from datetime import datetime, timedelta
from pathlib import Path as Path_T
from urllib.error import HTTPError
from urllib.parse import urlencode
from urllib.request import Request
from urllib.request import (
    HTTPBasicAuthHandler, HTTPPasswordMgrWithDefaultRealm,
    OpenerDirector,
)
import json
import logging
import typing as py

log = logging.getLogger(__name__)


REDCAP_API = 'https://redcap.kumc.edu/api/'

DS_DETERMINED = '92'

WebBuilder = py.Callable[..., OpenerDirector]


def main(argv: py.List[str], env: py.Dict[str, str], stdout: py.IO[str],
         cwd: Path_T, now: py.Callable[[], datetime],
         build_opener: WebBuilder) -> None:

    if '--get-status' in argv:
        [username, passkey, api_passkey] = argv[2:5]
        opener = DSConnectSurvey.basic_opener(build_opener,
                                              creds=(username, env[passkey]))
        ds = DSConnectSurvey(opener, api_key=env[api_passkey])
        ds._integration_test(stdout)
    elif '--send-consent' in argv:
        [api_passkey] = argv[2:3]
        svc = ConsentToLink(REDCAP_API, build_opener(), env[api_passkey])
        svc._integration_test(cwd, now())
    else:
        raise ValueError(argv)


class REDCapAPI:
    def __init__(self, url: str,
                 opener: OpenerDirector, api_token: str) -> None:
        self.url = url
        self.__opener = opener
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
        req = Request(self.url,
                      data=urlencode(data).encode('utf-8'))
        resp = self.__opener.open(req)
        records = py.cast(py.List[py.Dict[str, str]], json.loads(resp.read()))
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
        req = Request(self.url,
                      data=urlencode({
                          'token': self.__api_token,
                          'content': 'pdf',
                          'record': record,
                          'instrument': instrument,
                          'returnFormat': 'json'
                      }).encode('utf-8'))
        resp = self.__opener.open(req)
        return py.cast(py.IO[bytes], resp)


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


class DSConnectSurvey:
    """DS-Connect API to get status of a survey: who made it how far?
    """
    url = 'https://dsconnect25.pxrds-test.com/component/api/survey/getstatus'

    def __init__(self, opener: OpenerDirector, api_key: str) -> None:
        self.__opener = opener
        self.__api_key = api_key

    @classmethod
    def basic_opener(cls, build_opener: WebBuilder,
                     creds: py.Tuple[str, str]) -> OpenerDirector:
        p = HTTPPasswordMgrWithDefaultRealm()
        username, password = creds
        p.add_password(None, cls.url, username, password)  # type: ignore

        auth_handler = HTTPBasicAuthHandler(p)
        return build_opener(auth_handler)

    def getstatus(self, stids: py.List[str]) -> py.List[object]:
        req = Request(self.url,
                      data=json.dumps({"stids": stids}).encode('utf-8'),
                      headers={
                          NoCap('Content-Type'): 'application/json',
                          NoCap('X-DSNIH-KEY'): self.__api_key,
                      })
        log.debug('getting status for %s:\ndata: %s\nheaders: %s',
                  stids, req.data, req.header_items())
        resp = self.__opener.open(req)
        return [status for status in json.loads(resp.read())]

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
        from urllib.request import build_opener

        logging.basicConfig(level=logging.DEBUG)
        main(argv[:], env=environ.copy(), stdout=stdout,
             cwd=Path('.'), now=datetime.now,
             build_opener=build_opener)

    _script_io()
