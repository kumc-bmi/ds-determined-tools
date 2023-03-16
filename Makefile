MYPY=mypy
PYTHON3=python
FLAKE8=flake8

SRCS=ref_code_gen.py ds_status_sync.py sds_flat.py

check: autopep autoblack lint doctest lint static

autopep: venv
	# "converting python code to PEP formate"
	. venv/bin/activate && \
	autopep8 .

autoblack: venv
	# "converting python code to BLACK formate"
	#. venv/bin/activate && \
	#black .

static: venv
	# ds_status_sync.py:311: error: unused "type: ignore" comment
	# ds_status_sync.py:343: error: unused "type: ignore" comment
	# using --no-warn-no-return to hide above error
	. venv/bin/activate && \
	$(MYPY) --strict $(SRCS) --no-warn-no-return

lint-import: venv
	# this does import sorting for you, where flak8-isort will check it for you
	. venv/bin/activate && \
	isort .

lint: $(SRCS) lint-import venv
	. venv/bin/activate && \
	$(FLAKE8) $(SRCS)

doctest: venv
	. venv/bin/activate && \
	$(PYTHON3) -m doctest $(SRCS)

set_env_variable:
	echo "Make sure to set REDCAP_API_TOKEN as env variable."

run_test: venv lint check doctest set_env_variable ref_code_gen.py
	. venv/bin/activate && \
	REDCAP_API_TOKEN=$(REDCAP_API_TOKEN) $(PYTHON3) ref_code_gen.py 5 5 test

run_production: venv lint check doctest set_env_variable ref_code_gen.py
	. venv/bin/activate && \
	REDCAP_API_TOKEN=$(REDCAP_API_TOKEN) $(PYTHON3) ref_code_gen.py 1000 5 production

integration_test: venv lint check doctest set_env_variable
	. venv/bin/activate && \
	REDCAP_API_TOKEN=$(REDCAP_API_TOKEN) $(PYTHON3) ref_code_gen.py 5 5 test

integration_test_pdf: venv lint check doctest set_env_variable
	. venv/bin/activate && \
	REDCAP_API_TOKEN=$(REDCAP_API_TOKEN) $(PYTHON3) ds_status_sync.py --send-consent REDCAP_API_TOKEN

debug: venv lint check
	. venv/bin/activate && \
	$(PYTHON3) $(SRC) --debug

.envrc:
	echo 'layout python3' >.envrc

install-dev-tools: venv
	. venv/bin/activate && \
	pip install mypy flake8

ds_sync: venv
	. venv/bin/activate && \
	which python &&  python --version &&\
	python ds_status_sync.py --get-status REDCAP_API_TOKEN DS_KEY >out/ds_status.json &&\
	python ds_status_sync.py --send-consent REDCAP_API_TOKEN DS_KEY

clean: venv_clear
	rm -rf out; mkdir -p out

venv:
	# "creating python virtual env"
	python3 -m venv venv
	. ./venv/bin/activate && \
	pip install --upgrade pip  && \
	pip install -r requirements.txt  && \
	pip freeze >  requirements_pip_freeze.txt  && \
	which pip && which python && python --version

venv_clear:
	# "deleting python virtual env"
	rm -rf venv || true

combine_ds_invitae_files:venv
	# "combining ds invitae files"
	. venv/bin/activate &&\
	which python &&  python --version &&\
	mkdir -p output &&\
	python combine_ds_invitae_files.py input/invitae output/invitae_14csv_in1.csv
