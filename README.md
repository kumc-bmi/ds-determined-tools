# DS-Determined Study Tools


## Referral Code Generator: REDCap Upload Usage

First create a REDCap project and get an API token with import access.

To generate a batch of 2 records from each of 3 sites:

```
$ REDCAP_API_TOKEN=XYZ... python3 ref_code_gen.py 2 3
2019-12-06 17:31:59 (INFO) sending: [('token', '...'), ('content', 'record'), ('data', '[{"record_id": '), ('format', 'json')]
2019-12-06 17:31:59 (INFO) result: {'count': 6}
```

## Self-Determination Inventory Status

`sds_flat.py` converts status info from JSON as provided by SDI to CSV
for convenient import into REDCap.


## DS-Connect Status API Client (WIP)

See `ds_status_sync.py`.


## Background

This design is somewhat based on experience with "golden tickets" from
the PCORNet Adaptable trial, though the use of referral codes in
research studies is hardly novel. See also `trial_invite_code` in the
PCORNet CDM.

Funding is provided by the NIH as part of the [Include project][i],
launched in June 2018.

Ref:
  - _Using PCORnet to Expand the DS-CONNECT Cohort Through Healthcare
    System Recruitment, Incorporating Electronic Health Records, and
    Assessing Self-Determination_

[i]: https://www.nih.gov/include-project

## Coding Style

We use `doctest`, `flake8` and `mypy` as detailed in `Makefile`.
