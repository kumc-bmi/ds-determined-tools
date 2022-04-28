"""ds_status_sync - sync DS-Connect status with KUMC REDCap

Usage:

export DS_KEY=...
export REDCAP_API_TOKEN=...

python ds_status_sync.py --get-status REDCAP_API_TOKEN DS_KEY
python ds_status_sync.py --send-consent REDCAP_API_TOKEN DS_KEY

For integration testing, add:

export DS_AUTH=...user:...pass

"""

import json
import logging
import typing as py
from abc import abstractmethod
from datetime import datetime, timedelta
from pathlib import Path as Path_T
from urllib.error import HTTPError

from requests import Request
from requests import Session as Session_T

from sds_flat import complete, flatten

log = logging.getLogger(__name__)

REDCAP_API = 'https://redcap.kumc.edu/api/'

DS_DETERMINED = '92'
STATUS_FORM = 'ds_connect_status'

WebBuilder = py.Callable[..., Session_T]
Record_T = py.Dict[str, str]

selected_survey_key = ["record_id",
                       "registerdate",
                       "lastvisitdate",
                       "lastupdatedate",
                       "s_1_title",
                       "s_1_completed",
                       "s_1_played_time",
                       "s_2_title",
                       "s_2_completed",
                       "s_2_played_time",
                       "s_3_title",
                       "s_3_completed",
                       "s_3_played_time",
                       "s_4_title",
                       "s_4_completed",
                       "s_4_played_time",
                       "s_5_title",
                       "s_5_completed",
                       "s_5_played_time",
                       "s_6_title",
                       "s_6_completed",
                       "s_6_played_time",
                       "s_7_title",
                       "s_7_completed",
                       "s_7_played_time",
                       "s_8_title",
                       "s_8_completed",
                       "s_8_played_time",
                       "ds_connect_status_complete"]


def select_recrods_surveys(records: py.List[Record_T],
                           selected_survey_key: py.List[str]) \
        -> py.List[Record_T]:
    output_records = []

    for record in records:
        output_record = {}
        for key in record:
            if key in selected_survey_key:
                output_record[key] = record[key]
        output_records.append(output_record)
    return output_records


def main(argv: py.List[str], env: py.Dict[str, str], stdout: py.IO[str],
         cwd: Path_T, now: py.Callable[[], datetime],
         make_session: WebBuilder) -> None:
    def study(api_passkey: str) -> DSConnectStudy:
        if 'DS_AUTH' in env:
            username, password = env['DS_AUTH'].split(':')
            session = DSConnectStudy.basic_session(make_session,
                                                   auth=(username, password))
        else:
            session = make_session()
        return DSConnectStudy(session, api_key=env[api_passkey])

    if '--get-status' in argv:
        [api_passkey, ds_key] = argv[2:4]
        ds = study(ds_key)
        rc = REDCapAPI(REDCAP_API, make_session(), env[api_passkey])
        status = ds.getstatus([DS_DETERMINED])
        records = list(complete(STATUS_FORM)(flatten(status)))
        records = select_recrods_surveys(records, selected_survey_key)
        json.dump({'status': status, 'records': records}, stdout, indent=2)
        rc.import_records(records)
    elif '--send-consent' in argv:
        [api_passkey, ds_key] = argv[2:4]
        svc = ConsentToLink(REDCAP_API, make_session(), env[api_passkey])
        if '--test' in argv:
            dest = SaveConsent(cwd)  # type: ConsentDest
        else:
            dest = study(ds_key)
        for record, doc in svc.pending(now()):
            dest.send_user_consent(record, doc)
    elif '--test-consent' in argv:
        [ds_key] = argv[2:3]
        dest = study(ds_key)
        dest.send_user_consent('subject 1', open('testpdf.pdf', 'rb').read())
    else:
        raise ValueError(argv)


class REDCapAPI:
    def __init__(self, url: str,
                 session: Session_T, api_token: str) -> None:
        self.url = url
        self.__session = session
        self.__api_token = api_token

    def import_records(self, records: py.List[Record_T]) -> int:
        req = self.import_request(self.url, self.__api_token, records)
        log.info('import records: url=%s', self.url)
        resp = self.__session.send(req.prepare())
        try:
            resp.raise_for_status()
        except Exception:
            log.error(resp.text)
            raise
        result = py.cast(py.Dict[str, int], resp.json())
        log.info('imported records: %s', result)
        return result['count']

    @classmethod
    def import_request(cls, url: str, token: str,
                       records: py.List[Record_T]) -> Request:
        """
        >>> r = REDCapAPI.import_request(
        ...     'https://redcap/api', 'sekret',
        ...     [{'a': 1}, {'a': 2}])
        >>> r = r.prepare()
        >>> r.body.split('&')  # doctest: +NORMALIZE_WHITESPACE
        ['token=sekret', 'content=record', 'format=json',
         'type=flat', 'returnFormat=json', 'returnContent=count',
         'data=%5B%7B%22a%22%3A+1%7D%2C+%7B%22a%22%3A+2%7D%5D']
        """
        data = {
            'token': token,
            'content': 'record',
            'format': 'json',
            'type': 'flat',
            'returnFormat': 'json',
            'returnContent': 'count',
            'data': json.dumps(records),
        }
        return Request('POST', url, data=data)

    def export_records(self, dateRangeBegin: datetime,
                       filterLogic: str,
                       fields_0: str) -> py.List[py.Dict[str, str]]:
        req = self.export_request(self.url, self.__api_token,
                                  dateRangeBegin, filterLogic, fields_0)
        log.info('export records: url=%s', self.url)
        log.debug('export records: data=%s', req.data)
        resp = self.__session.send(req.prepare())
        resp.raise_for_status()
        records = py.cast(py.List[py.Dict[str, str]], resp.json())
        log.debug('exported records: %s', records)
        return records

    @classmethod
    def export_request(cls, url: str, token: str,
                       dateRangeBegin: datetime,
                       filterLogic: str,
                       fields_0: str) -> Request:
        """
        >>> r = REDCapAPI.export_request(
        ...     'https://redcap/api', 'sekret', datetime(2001, 1, 1),
        ...     "[consent_to_link_complete] = '2'", 'record_id')
        >>> r = r.prepare()
        >>> r.body[:62]
        'token=sekret&content=record&format=json&type=flat&filterLogic='
        >>> r.body[62:119]
        '%5Bconsent_to_link_complete%5D+%3D+%272%27&fields%5B0%5D='
        >>> r.body[119:]
        'record_id&returnFormat=json&dateRangeBegin=2001-01-01+00%3A00%3A00'
        """
        data = {
            'token': token,
            'content': 'record',
            'format': 'json',
            'type': 'flat',
            'filterLogic': filterLogic,
            'fields[0]': fields_0,
            'returnFormat': 'json',
            'dateRangeBegin': cls._fmt_time(dateRangeBegin),
        }
        return Request('POST', url, data=data)

    @classmethod
    def _fmt_time(cls, when: datetime) -> str:
        """
        >>> # noinspection PyProtectedMember
        ... REDCapAPI._fmt_time(datetime(2017, 1, 1))
        '2017-01-01 00:00:00'
        """
        return when.strftime('%Y-%m-%d %H:%M:%S')

    def export_pdf(self, instrument: str, record: str) -> bytes:
        req = self.pdf_request(self.url, self.__api_token, record, instrument)
        resp = self.__session.send(req.prepare())
        resp.raise_for_status()
        pdf = b''
        for chunk in resp.iter_content(chunk_size=1024):
            pdf += chunk
        return pdf

    @classmethod
    def pdf_request(cls, url: str, token: str,
                    record: str, instrument: str) -> Request:
        """
        >>> r = REDCapAPI.pdf_request(
        ...     'https://redcap/api', 'sekret', 'SB-0001', 'stuff')
        >>> r = r.prepare()
        >>> r.body
        'token=sekret&content=pdf&record=SB-0001&instrument=stuff&returnFormat=json'
        """
        return Request('POST', url,
                       data={
                           'token': token,
                           'content': 'pdf',
                           'record': record,
                           'instrument': instrument,
                           'returnFormat': 'json'
                       })


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

    def consent_form(self, record: str) -> bytes:
        return self.export_pdf(self.instrument, record)

    def pending(self, now: datetime) -> py.Iterator[py.Tuple[str, bytes]]:
        try:
            for record in self.consented_since(now - self.recent):
                log.info('get consent form: record_id=%s', record)
                src = self.consent_form(record)
                yield record, src
        except HTTPError as err:
            log.error('error %s %s\n%s\n%s',
                      err.code, err.reason, err.headers, err.read())
            raise


class ConsentDest:
    @abstractmethod
    def send_user_consent(self, sbjid: str, consent_pdf: bytes) -> None:
        raise NotImplementedError


class DSConnectStudy(ConsentDest):
    """DS-Connect API for a study
    """

    base = 'https://dsconnect.nih.gov/'
    # test:
    # base = 'https://dsconnect25.pxrds-test.com/'

    # the default, python-requests, gets a 403 somehow
    user_agent = 'ds_status_sync/2021.02.05'

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
        req = self.status_request(self.__api_key, stids)
        log.debug('getting status for %s:\ndata: %s\nheaders: %s',
                  stids, req.data, req.headers.items())
        s = self.__session
        resp = s.send(s.prepare_request(req))  # type: ignore
        resp.raise_for_status()
        return [status for status in resp.json()]

    @classmethod
    def status_request(cls, api_key: str, stids: py.List[str]) -> Request:
        """
        >>> r = DSConnectStudy.status_request('sekret', ['20'])
        >>> r = r.prepare()
        >>> r.headers
        ... # doctest: +NORMALIZE_WHITESPACE
        {'Content-Type': 'application/json', 'X-DSNIH-KEY': 'sekret',
         'User-Agent': 'ds_status_sync/2021.02.05',
         'Content-Length': '17'}
        >>> r.body
        b'{"stids": ["20"]}'
        """
        url = cls.base + 'component/api/survey/getstatus'
        req = Request('POST', url,
                      json={"stids": stids},
                      headers={
                          'Content-Type': 'application/json',
                          'X-DSNIH-KEY': api_key,
                          'User-Agent': cls.user_agent,
                      })
        return req

    def send_user_consent(self, sbjid: str, consent_pdf: bytes) -> None:
        log.info('sending %d byte consent form for subject %s',
                 len(consent_pdf), sbjid)
        req = self.consent_request(self.__api_key, consent_pdf, sbjid)
        s = self.__session
        resp = s.send(s.prepare_request(req))  # type: ignore
        resp.raise_for_status()
        log.info('sent consent form for %s', sbjid)

    @classmethod
    def consent_request(cls, api_key: str,
                        consent_pdf: bytes, sbjid: str) -> Request:
        r"""
        >>> r = DSConnectStudy.consent_request('sekret', b'pdfpdf', 'bob')
        >>> r = r.prepare()

        >>> r.url
        'https://dsconnect.nih.gov/component/api/user/consent'

        >>> r.headers
        ... # doctest: +ELLIPSIS +NORMALIZE_WHITESPACE
        {'X-DSNIH-KEY': 'sekret', 'User-Agent': 'ds_status_sync/2021.02.05',
         'Content-Length': '409',
         'Content-Type': 'multipart/form-data; boundary=...'}

        >>> r.body
        ... # doctest: +ELLIPSIS +NORMALIZE_WHITESPACE
        b'--...\r\nContent-Disposition: form-data;
        name="stid"\r\n\r\n92\r\n--...\r\nContent-Disposition:
        form-data; name="sbjid"\r\n\r\nbob\r\n--...\r\nContent-Disposition:
        form-data; name="share"\r\n\r\n1\r\n--...\r\nContent-Disposition:
        form-data; name="file"; filename="file"\r\n\r\npdfpdf\r\n--...--\r\n'

        """
        req = Request('POST', cls.base + 'component/api/user/consent',
                      headers={
                          'X-DSNIH-KEY': api_key,
                          'User-Agent': cls.user_agent,
                      },
                      files={'file': consent_pdf},
                      data={
                          'stid': DS_DETERMINED,
                          'sbjid': sbjid,
                          'share': 1,
                      })
        return req

    def dump_status(self, stdout: py.IO[str]) -> None:
        try:
            status = self.getstatus([DS_DETERMINED])
            log.debug('status: %s', status)
            json.dump(status, stdout, indent=2)
        except HTTPError as err:
            log.error('error %s %s\n%s\n%s',
                      err.code, err.reason, err.headers, err.read())
            raise


class SaveConsent(ConsentDest):
    """
    Save consent docs to local files. Mostly for testing.
    """

    def __init__(self, dest: Path_T):
        self.__dest = dest

    def send_user_consent(self, record: str,
                          consent_pdf: bytes) -> None:
        dest = (self.__dest / record).with_suffix('.pdf')
        with dest.open('wb') as out:
            out.write(consent_pdf)
            log.info('saved %d bytes to %s', len(consent_pdf), dest)


if __name__ == '__main__':
    def _script_io() -> None:
        from datetime import datetime
        from os import environ
        from pathlib import Path
        from sys import argv, stderr, stdout

        from requests import Session

        if '--debug' in argv:
            import http.client as http_client
            http_client.HTTPConnection.debuglevel = 1  # type: ignore

        logging.basicConfig(level=logging.DEBUG, stream=stderr)
        main(argv[:], env=environ.copy(), stdout=stdout,
             cwd=Path('.'), now=datetime.now,
             make_session=lambda: Session())

    _script_io()
