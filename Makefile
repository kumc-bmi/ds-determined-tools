MYPY=mypy
PYTHON3=python
FLAKE8=flake8

SRC=ref_code_gen.py

check: doctest lint
	$(MYPY) --strict $(SRC)

lint:
	$(FLAKE8) $(SRC)

doctest:
	$(PYTHON3) -m doctest $(SRC)

run: lint check doctest
	$(PYTHON3) $(SRC)

integration_test: lint check doctest
	REDCAP_API_TOKEN=$(REDCAP_API_TOKEN) $(PYTHON3) $(SRC) 2 3

debug: lint check
	$(PYTHON3) $(SRC) --debug

.envrc:
	echo 'layout python3' >.envrc

install-dev-tools:
	pip install mypy flake8
