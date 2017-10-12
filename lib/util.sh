P6_TEST_DIR_BASE=${TMPDIR:-/tmp}/p6test
P6_TEST_DIR=
P6_TEST_DIR_ORIG=
P6_TEST_BAIL_FILE=$P6_TEST_BASE_DIR/bail

p6_test_dir() {
    local prefix="$1"

    local dir_name
    if [ -z "$prefix" ]; then
	dir_name=$P6_TEST_DIR
    else
	local rand=$(cat /dev/urandom | env LC_CTYPE=C tr -dc a-zA-Z0-9 | head -c 5)
	dir_name="$P6_TEST_DIR_BASE/$prefix/$rand"

	mkdir -p $dir_name
    fi

    echo $dir_name
}

p6_test__initialize() {
    local n="$1"

    mkdir -p $P6_TEST_DIR_BASE

    echo 1 > $P6_TEST_DIR_BASE/i
    echo "$n" > $P6_TEST_DIR_BASE/n
}

p6_test__prep() {

    P6_TEST_DIR=$(p6_test_dir "t")
    P6_TEST_DIR_ORIG=$(pwd)
    cd $P6_TEST_DIR
    set -e
}

p6_test__bailout() {

    echo 1 > $P6_TEST_BAIL_FILE
}

p6_test__cleanup() {

    set +e
    cd $P6_TEST_DIR_ORIG
#    rm -rf $P6_TEST_DIR

    if [ -e $P6_TEST_BAIL_FILE ]; then
	echo 1
    else
	echo 0
    fi
    rm -f $P6_TEST_BAIL_FILE
}

p6_test__i() {

    local current=$(cat $P6_TEST_DIR_BASE/i)
    local next=$(($current+1))

    echo $next > $P6_TEST_DIR_BASE/i

    echo $current
}
