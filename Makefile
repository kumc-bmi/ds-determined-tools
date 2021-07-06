MYPY=mypy
PYTHON3=python
FLAKE8=flake8

SRCS=ref_code_gen.py ds_status_sync.py sds_flat.py

check: autopep autoblack lint doctest lint static

autopep:
	# "converting python code to PEP formate"
	autopep8 .

autoblack:
	# "converting python code to BLACK formate"
	#black .

static:
	# ds_status_sync.py:311: error: unused "type: ignore" comment
	# ds_status_sync.py:343: error: unused "type: ignore" comment
	# using --no-warn-no-return to hide above error
	$(MYPY) --strict $(SRCS) --no-warn-no-return

lint-import:
	# this does import sorting for you, where flak8-isort will check it for you
	isort .

lint: $(SRCS) lint-import
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

ds_sync: clean venv
	. venv/bin/activate && \
	which python &&  python --version &&\
	python ds_status_sync.py --get-status REDCAP_API_TOKEN DS_KEY >out/ds_status.json \
	python ds_status_sync.py --send-consent REDCAP_API_TOKEN DS_KEY

clean:
	rm -rf out; mkdir -p out

venv: venv_clear
	# "creating python virtual env"
	python -m venv venv
	. ./venv/bin/activate && \
	pip install --upgrade pip  && \
	pip install -r requirements.txt  && \
	pip freeze >  requirements_pip_freeze.txt  && \
	which pip && which python && python --version

venv_clear:
	# "deleting python virtual env"
	rm -rf venv || true
