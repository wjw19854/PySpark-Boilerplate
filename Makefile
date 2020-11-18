
help:
	@echo "clean - remove all build, test, coverage and Python artifacts"
	@echo "clean-pyc - remove Python file artifacts"
	@echo "clean-test - remove test and coverage artifacts"
	@echo "lint - check style"
	@echo "test - run tests quickly with the default Python"
	@echo "coverage - check code coverage quickly with the default Python"
	@echo "build - package"

all: default

default: clean dev_deps deps test lint build

.venv:
	if [ ! -e ".venv/bin/activate_this.py" ] ; then virtualenv --clear .venv ; fi

clean: clean-build clean-pyc clean-test

clean-build:
	rm -fr dist/

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test:
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/

deps: .venv
	. .venv/bin/activate && pip install -U -r requirements.txt -t ./src/libs

dev_deps: .venv
	. .venv/bin/activate && pip install -U -r dev_requirements.txt

lint:
	. .venv/bin/activate && pylint -r n src/main.py src/shared src/jobs tests

test:
	. .venv/bin/activate && nosetests ./tests/* --config=.noserc

build: clean
	mkdir ./dist
	cp ./src/main.py ./dist
	cd ./src && zip -x main.py -x \*libs\* -r ../dist/jobs.zip .
	cd ./src/libs && zip -r ../../dist/libs.zip .
# run:
# curl --request POST \
# --url http://ip-172-24-21-212.cn-northwest-1.compute.internal:8998/batches \
# --header 'content-type: application/json' \
# --data '{
# "file": "s3://bi-data-store/code/spark-test/v0.1/main.py",
# "pyFiles": [
# "s3://bi-data-store/code/spark-test/v0.1/jobs.zip",
# "s3://bi-data-store/code/spark-test/v0.1/libs.zip"
# ],
# "args": [
# 		"--job", "wordcount"
# 	]
# }'

# curl -X GET -i 'http://ip-172-24-21-212.cn-northwest-1.compute.internal:8998/batches/2'