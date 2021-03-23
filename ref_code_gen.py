"""ref_code_gen -- generate referral codes in REDCap

We can make a batch of 2 records from each of 3 sites::

    >>> b = ReferralCode.batch(2, 3, 'production')
    >>> print(pformat(b))
    [{'record_id': 'SA-00004', 'redcap_data_access_group': 'sa'},
     {'record_id': 'SA-00016', 'redcap_data_access_group': 'sa'},
     {'record_id': 'SB-00002', 'redcap_data_access_group': 'sb'},
     {'record_id': 'SB-00018', 'redcap_data_access_group': 'sb'},
     {'record_id': 'SC-00003', 'redcap_data_access_group': 'sc'},
     {'record_id': 'SC-00013', 'redcap_data_access_group': 'sc'}]

    >>> b = ReferralCode.batch(2, 3, 'test')
    >>> print(pformat(b))
    [{'record_id': 'SA-_TEST_00009', 'redcap_data_access_group': 'sa'},
     {'record_id': 'SA-_TEST_00019', 'redcap_data_access_group': 'sa'},
     {'record_id': 'SB-_TEST_00007', 'redcap_data_access_group': 'sb'},
     {'record_id': 'SB-_TEST_00017', 'redcap_data_access_group': 'sb'},
     {'record_id': 'SC-_TEST_00008', 'redcap_data_access_group': 'sc'},
     {'record_id': 'SC-_TEST_00014', 'redcap_data_access_group': 'sc'}]
"""

from binascii import crc32
from pprint import pformat
from urllib.error import HTTPError
from urllib.parse import urlencode
from urllib.request import OpenerDirector as OpenerDirector_T
import json
import logging
import typing as py

log = logging.getLogger(__name__)

Record = py.Dict[str, object]


def main(argv: py.List[str], environ: py.Dict[str, str],
         basicConfig: py.Callable[..., None],
         web_ua: OpenerDirector_T) -> None:
    basicConfig(
        format='%(asctime)s (%(levelname)s) %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S',
        level=logging.DEBUG if '--debug' in argv
        else logging.INFO)
    if '--debug' in argv:
        argv.remove('--debug')

    batch_size = int(argv[1]) if len(argv) >= 2 else ReferralCode.batch_size
    site_qty = int(argv[2]) if len(argv) >= 3 else ReferralCode.site_qty
    invite_code_type = argv[3]

    batch = ReferralCode.batch(batch_size, site_qty, invite_code_type)
    log.debug('batch: %s', batch)

    p1 = Project(web_ua, Project.kumc_redcap_api, environ[Project.key])
    p1.import_records(batch)


class ReferralCode:
    batch_size = 100
    site_qty = 5

    @classmethod
    def batch(cls, batch_size: int, site_qty: int,
              invite_code_type: str) -> py.List[Record]:

        if invite_code_type == 'production':
            base_len: int = len('SA-1234')
            invite_code: str = ''
        elif invite_code_type == 'test':
            invite_code = '_TEST_'
            base_len = len('SA-_TEST_1234')

        sites = [f'S{chr(ord("A") + site_ix)}' for site_ix in range(site_qty)]
        return [{'record_id': cls.check_digit(
                 f'{site}-{invite_code}{n:04d}', base_len),
                 'redcap_data_access_group': site.lower()}
                for site in sites
                for n in range(batch_size)]

    @classmethod
    def check_digit(cls, candidate: str,
                    base_len: int = len('SA-1234')) -> str:
        """Add or verify check digit.

        Add check digit when not present:

        >>> ReferralCode.check_digit('SB-0025')
        'SB-00253'

        Verify when present:

        >>> ReferralCode.check_digit('SB-00018')
        'SB-00018'

        >>> ReferralCode.check_digit('SB-00025')
        Traceback (most recent call last):
          ...
        ValueError: SB-00025

        """
        base = candidate[:base_len]
        crc = crc32(base.encode('utf-8'))
        digit = crc % 10
        out = f'{base}{digit}'
        # print(candidate, base_len, base, crc, digit, out)
        if out != candidate and len(candidate) > base_len:
            raise ValueError(candidate)
        return out


class Project:
    '''Access to a REDCap Project to import_records()
    '''

    kumc_redcap_api = 'https://redcap.kumc.edu/api/'
    key = 'REDCAP_API_TOKEN'

    def __init__(self, ua: OpenerDirector_T, url: str, api_token: str) -> None:
        self.__ua = ua
        self.url = url
        self.__api_token = api_token

    def import_records(self, data: py.List[Record]) -> object:
        ua, url, api_token = self.__ua, self.url, self.__api_token

        form = [('token', api_token),
                ('content', 'record'),
                ('data', json.dumps(data)),
                ('format', 'json')]
        log.info('sending: %s', [(k, v[:15] if k != 'token' else '...')
                                 for (k, v) in form])
        log.debug('sending: %s', data)
        try:
            reply = ua.open(url, urlencode(form).encode('utf8'))
        except HTTPError as err:
            body = err.read()
            try:
                body = json.loads(body)
            except ValueError:
                pass
            log.error('code: %d\n%s', err.code, pformat(body))
            raise
        if reply.getcode() != 200:
            raise IOError(reply.getcode())

        result = json.load(reply)  # type: py.Dict[str, object]
        log.info('result: %s', result)
        if ('error' in result or 'count' not in result):
            raise IOError(result)
        return result


if __name__ == '__main__':
    def _script_io() -> None:
        from sys import argv
        from os import environ
        from urllib.request import build_opener

        main(argv[:], environ.copy(), logging.basicConfig, build_opener())

    _script_io()
