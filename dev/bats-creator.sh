#!/bin/bash
# we want to exit if any command fails
set -e

DEV_MODE=false

# if we enter we --force flag, we will delete everything done by this script
if [[ $1 == "--force" ]]; then
    DEV_MODE=true
fi

if [[  $DEV_MODE == "true" ]]; then
    # set -x
    # for test delete everything done
    rm -rf ./.git
    rm -rf ./src
    rm -rf ./test
    # todo exit if src or test folder exist
fi

if [[ -d ./src ]]; then
    echo "src folder already exist. Please delete it before running this script."
    exit 1
fi

if [[ -d ./test ]]; then
    echo "test folder already exist. Please delete it before running this script."
    exit 1
fi

function _not_understood_answer() {
    echo "I don't understand your answer. Please answer with y or n"
    exit 1
}

function _set_output_to_red(){
    tput setaf 1
}

function _set_output_to_purple() {
    tput setaf 171
}

function _set_output_reset_style() {
    tput sgr0
}

function _no_git_folder_error() {
    _set_output_to_red
    printf "\n"
    echo "Please init a git repository before using this script."
    _set_output_reset_style
    exit 1
}

function _create_common_setup(){
    # creation of file
    common_setup_file_path="test/test_helper/common-setup"
    touch $common_setup_file_path
    # set contents
    {
    echo "#!/bin/bash" 
    echo "_common_setup() {";
    echo "load 'test_helper/bats-support/load'";
    echo "load 'test_helper/bats-assert/load'";
    echo "load 'helpers/mocks/stub'";

    echo "echo # get the containing directory of this file";
    echo "# use \$BATS_TEST_FILENAME instead of \${BASH_SOURCE[0]} or \$0,";
    echo "# as those will point to the bats executable's location or the preprocessed file respectively";
    echo "DIR=\"\$( cd \"\$( dirname \"\$BATS_TEST_FILENAME\" )\" >/dev/null 2>&1 && pwd )\"";
    echo "# make executables in src/ visible to PATH";
    echo "PATH=\"\$DIR/../src:\$PATH\"";

    echo "}";
    echo "_common_setup";
    } >> $common_setup_file_path
}

function _create_test_bats_file(){
    # creation of file
    test_bats_file="test/test.bats"
    touch $test_bats_file
    # set contents of example test file
    {
        echo "setup() {";
        echo "load \"test_helper/common-setup\"";
        echo "}";

        echo ""
        echo "@test \"our first test\" {";
        echo "  # replace with your actual script";
        echo "  run my_script";
        echo "  assert_output --partial \"Hello World\"";
        echo "  assert_success";
        echo "}";

    } >> $test_bats_file
}

function _create_example_script_file() {
    # creation of file
    script_file="src/my_script.sh"
    touch $script_file

    # set contents of example script file
    {
        echo "#!/bin/bash";
        echo "echo \"Hello World\"";
    } >> $script_file

    # be able to execute the script
    chmod +x $script_file
}



# if no .git folder exist, we ask the user if he want us to create it
if [ ! -d .git ]; then
    echo "No .git folder found. Do you want to create one? [Y/n]"
    read -r -n 1 answer
    # default Value = Y
    answer=${answer:-Y}

    case $answer in 
    "y"|"Y") git init ;;
    "n"|"N") _no_git_folder_error ;;
    *) _not_understood_answer ;;
    esac
fi

# first we create the src folder
mkdir src
mkdir test


# first we install the required submodules
_set_output_to_purple
echo "Installing required submodules..."
_set_output_reset_style
git submodule add https://github.com/bats-core/bats-core.git test/bats
git submodule add https://github.com/bats-core/bats-support.git test/test_helper/bats-support
git submodule add https://github.com/bats-core/bats-assert.git test/test_helper/bats-assert
git submodule add https://github.com/buildkite-plugins/bats-mock test/helpers/mocks


# creation of common-setup file in test_helper/common-
_create_common_setup

# creation of file in test/test.bats
_create_test_bats_file

# creation of example script file
_create_example_script_file


# all files have been created, now we should be able to run the test
echo ""
echo "------------------------------------"
echo "Done. You can now run your tests with:"
_set_output_to_purple
echo "  ./test/bats/bin/bats test/test.bats"
_set_output_reset_style
echo "------------------------------------"
echo "  or (if you have bats installed globally):"
_set_output_to_purple
echo "  bats test/test.bats"
_set_output_reset_style
echo "------------------------------------"
echo "Happy testing !"

