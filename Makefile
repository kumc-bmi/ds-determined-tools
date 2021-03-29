MYPY=mypy
PYTHON3=python
FLAKE8=flake8

SRCS=ref_code_gen.py ds_status_sync.py sds_flat.py

check: doctest lint static

static:
	$(MYPY) --strict $(SRCS)

lint: $(SRCS)
	$(FLAKE8) $(SRCS)

doctest:
	$(PYTHON3) -m doctest $(SRCS)

set_env_variable:
	echo "Make sure to set REDCAP_API_TOKEN as env variable."

run_test: lint check doctest set_env_variable ref_code_gen.py
	REDCAP_API_TOKEN=$(REDCAP_API_TOKEN) $(PYTHON3) ref_code_gen.py 5 5 test

run_production: lint check doctest set_env_variable ref_code_gen.py
	REDCAP_API_TOKEN=$(REDCAP_API_TOKEN) $(PYTHON3) ref_code_gen.py 1000 5 production

integration_test: lint check doctest set_env_variable
	REDCAP_API_TOKEN=$(REDCAP_API_TOKEN) $(PYTHON3) ref_code_gen.py 5 5 test

integration_test_pdf: lint check doctest set_env_variable
	REDCAP_API_TOKEN=$(REDCAP_API_TOKEN) $(PYTHON3) ds_status_sync.py --send-consent REDCAP_API_TOKEN

debug: lint check
	$(PYTHON3) $(SRC) --debug

.envrc:
	echo 'layout python3' >.envrc

install-dev-tools:
	pip install mypy flake8
