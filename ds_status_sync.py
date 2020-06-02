"""ds_status_sync - sync DS-Connect status with KUMC REDCap

Integration Test Usage:

export DS_PASS=...
export DS_KEY=...
python ds_status_sync.py user123 DS_PASS DS_KEY

"""

from urllib.error import HTTPError
from urllib.request import Request
from urllib.request import (
    HTTPBasicAuthHandler, HTTPPasswordMgrWithDefaultRealm,
    OpenerDirector,
)
import json
import logging
import typing as py

log = logging.getLogger(__name__)


TEST_STIDS = [91, 90]

WebBuilder = py.Callable[..., OpenerDirector]


def main(argv: py.List[str], env: py.Dict[str, str],
         build_opener: WebBuilder) -> None:
    [username, passkey, api_passkey] = argv[1:4]

    creds = (username, env[passkey])
    opener = DSConnectSurvey.basic_opener(build_opener, creds)
    ds = DSConnectSurvey(opener, api_key=env[api_passkey])
    try:
        status = ds.getstatus(TEST_STIDS)
        log.info('status: %s', status)
    except HTTPError as err:
        log.error('error %s %s\n%s\n%s',
                  err.code, err.reason, err.headers, err.read())
        raise


class DSConnectSurvey:
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

    def getstatus(self, stids: py.List[int]) -> py.List[object]:
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
        from os import environ
        from sys import argv
        from urllib.request import build_opener

        logging.basicConfig(level=logging.INFO)
        main(argv[:], env=environ.copy(), build_opener=build_opener)

    _script_io()
