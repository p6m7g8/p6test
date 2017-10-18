p6_test_dir() {
    local path="$1"

    local dir_name
    if [ -z "$path" ]; then
	dir_name=$P6_TEST_DIR_ROOT
    else
	local rand=$(cat /dev/urandom | env LC_CTYPE=C tr -dc a-zA-Z0-9 | head -c 5)
	dir_name="$path/$rand"

	mkdir -p $dir_name
    fi

    echo $dir_name
}

p6_test__init() {

    P6_LF='
'
    local tmpdir=${TMPDIR:-/tmp}
    P6_DIR=$tmpdir/p6

    P6_TEST_DIR=$P6_DIR/test
    P6_TEST_DIR_ROOT=

    P6_TEST_BAIL_FILE=$P6_TEST_DIR/bail

    P6_TEST_DIR_ORIG=`pwd`
}

p6_test__initialize() {
    local n="$1"

    p6_test__init
    trap p6_test_teardown 0 1 2 3 6 14 15
    mkdir -p $P6_TEST_DIR

    echo 1 > $P6_TEST_DIR/i
    echo "$n" > $P6_TEST_DIR/n
}

p6_test__prep() {

    P6_TEST_DIR_ROOT=$(p6_test_dir "$P6_TEST_DIR")
    cd $P6_TEST_DIR_ROOT
}

p6_test__bailout() {

    echo 1 > $P6_TEST_BAIL_FILE
}

p6_test__cleanup() {

    cd $P6_TEST_DIR_ORIG
    rm -rf $P6_TEST_DIR_ROOT

    if [ -e $P6_TEST_BAIL_FILE ]; then
	echo 1
    else
	echo 0
    fi
    rm -f $P6_TEST_BAIL_FILE
}

p6_test__i() {

    local current=$(cat $P6_TEST_DIR/i)
    local next=$(($current+1))

    echo $next > $P6_TEST_DIR/i

    echo $current
}
