import csv
import json
import typing as py


RECORD_ID = 'sbjid'


def main(stdin: py.TextIO, stdout: py.TextIO) -> None:
    status = json.load(stdin)
    to_csv(status, stdout)


def to_csv(status: py.List[py.Any], out: py.TextIO) -> None:
    cols = set()
    for flatr in flatten(status):
        for col in flatr.keys():
            cols.add(col)
    hd = ['record_id'] + [col for col in cols if col != 'record_id']
    cw = csv.DictWriter(out, hd)
    cw.writerow(dict(zip(hd, hd)))
    for flatr in flatten(status):
        cw.writerow(flatr)


def flatten(records: py.List[py.Any]) -> py.Iterable[py.Dict[str, str]]:
    for record in records:
        flatr = {}
        for prop, val in record.items():
            if type(val) is list:
                for ix, item in enumerate(val):
                    for iprop, ival in item.items():
                        col = "%s_%s_%s" % (prop[:1], ix + 1, iprop)
                        flatr[col.lower()] = ival
            else:
                if prop == RECORD_ID:
                    prop = 'record_id'
                if val == '0000-00-00 00:00:00':
                    continue
                flatr[prop.lower()] = val
        yield flatr


if __name__ == '__main__':
    def _script() -> None:
        from sys import stdin, stdout

        main(stdin, stdout)

    _script()
