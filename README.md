# Bats Project Creator

## What is it ?

If you want to create a linux script with unit testing with bats, you must do some configuration steps. This script aims at helping you with a template ready to write and launch your unit tests.

## Usage

Download and execute the script at `./dev/bats-creator.sh`.
It will ask you the name of your script.
The script will generate all configuration for utilisation of bats.
Write your test in `test` folder, by naming new file with `.bats` extension.
An example of test file is available at `./test/test.bats`

You can also run `run-tests.sh` to run all `.bats` test files in `test` folder.

See the **bats** official documentation [here](https://bats-core.readthedocs.io/en/stable/)
