# shellcheck shell=bash
# t - total number of planed tests. From the TAP plan.
# s - number of tests ok (includes TODO tests not accidentally passing)
# S - number of tests SKIPPED
# T - number of tests TODO (currently correctly failing as its TODO)
# B - GOOD NEWS, number of tests accidentally passing, REMOVE TODO.
# F - BAD NEWS, you have bugs, number of tests not ok
# r - number of tests run (S+T+F+s)
# P - number of tests ok (S+s+T)
# p - percentage of tests passing (P/t)*100
# d - time delta

######################################################################
#<
#
# Function: p6_test_harness_test_run()
#
#>
######################################################################
p6_test_harness_test_run() {
    local file="$1"

    local Tt=0
    local Ts=0
    local TS=0
    local TT=0
    local TB=0
    local TF=0

    ## Setup env
    local test_env
    test_env=$(env | grep -E "^(EDITOR|DISPLAY|HOME|PWD|SHELL|SHLVL|TMPDIR|USER|TERM|PATH|P6_TEST_)=" | xargs)

    # Log file
    local log_file
    log_file=$P6_TEST_DIR/tests/$(basename "$file").txt
    local log_file_times=$log_file-time
    local dir
    dir=$(dirname "$log_file")
    mkdir -p "$dir"

    ## Time and run
    time /usr/bin/env -i P6_TEST_COLOR_OFF=1 "$test_env" ./"$file"

    local IFS='
'
    echo "$log_file" >&2
    cat "$log_file" >&2

    local line
    for line in $(cat "$log_file"); do
        case $line in
        1..*)
            Tt=$(echo "$line" | sed -e 's,^1..,,' -e 's, *,,')
            ;;
        ok\ *SKIP*\ *)
            TS=$(p6_test__math_inc "$TS")
            ;;
        not\ *TODO\ *)
            TT=$(p6_test__math_inc "$TT")
            ;;
        ok\ *TODO\ *)
            TB=$(p6_test__math_inc "$TB")
            Ts=$(p6_test__math_inc "$Ts")
            ;;
        not\ ok*)
            TF=$(p6_test__math_inc "$TF")
            ;;
        ok\ *)
            Ts=$(p6_test__math_inc "$Ts")
            ;;
        esac
    done

    if [ $TF -eq 0 ]; then
        rm -f "$log_file"
    fi

    local Tr
    Tr=0
    Tr=$(p6_test__math_inc "$Tr" "$TS" "$TT" "$TF" "$Ts")
    local TP
    TP=0
    TP=$(p6_test__math_inc "$TS" "$Ts" "$TT")

    local Tp
    case $Tt in
    0) Tp=0.00 ;;
    *) Tp=$(p6_test__math_percent "$TP" "$Tt") ;;
    esac

    # 0m0.330s
    local Td
    Td=$(awk '/real/ { print $1 }' "$log_file_times" | sed -e 's,^0m,,' -e 's/s//')
    if [ -z "$Td" ]; then
        Td=0
    fi

    echo "Tt=$Tt Ts=$Ts TS=$TS TT=$TT TB=$TB TF=$TF Tr=$Tr Tp=$Tp TP=$TP Td=$Td"
}

######################################################################
#<
#
# Function: p6_test_harness_tests_run(dir)
#
#  Args:
#	dir -
#
#>
######################################################################
p6_test_harness_tests_run() {
    local dir="$1"

    local f=0
    local t=0
    local i=0
    local S=0
    local T=0
    local B=0
    local p=0
    local P=0
    local d=0

    p6_test__init
    local file
    if [ -d "$dir" ]; then
        for file in $(
            cd "$dir" || exit 0
            ls -1
        ); do
            local vals
            vals="$(p6_test_harness_test_run "$dir/$file")"

            local ti
            ti=$(echo "$vals" | sed -e 's,.*Tt=,,' -e 's, .*,,')
            local pi
            pi=$(echo "$vals" | sed -e 's,.*Tp=,,' -e 's, .*,,')
            local Pi
            Pi=$(echo "$vals" | sed -e 's,.*TP=,,' -e 's, .*,,')
            local Si
            Si=$(echo "$vals" | sed -e 's,.*TS=,,' -e 's, .*,,')
            local Ti
            Ti=$(echo "$vals" | sed -e 's,.*TT=,,' -e 's, .*,,')
            local Bi
            Bi=$(echo "$vals" | sed -e 's,.*TB=,,' -e 's, .*,,')
            local di
            di=$(echo "$vals" | sed -e 's,.*Td=,,' -e 's, .*,,')

            t=$(($t + $ti))
            P=$(($P + $Pi))
            B=$(($B + $Bi))
            S=$(($S + $Si))
            T=$(($T + $Ti))
            p=$(p6_test__math_inc "$p" "$pi")
            d=$(p6_test__math_inc "$d" "$di")

            p6_test_harness___results "$dir/$file" "$di" "$pi" "$Pi" "$ti" "$Bi" "$Ti" "$Si" >&2
            f=$(($f + 1))
        done
    fi
    local result
    local msg
    local rc

    if [ x"$P" != x"$t" ]; then
        msg=$(grep -E '^not ok|^#' "$P6_TEST_DIR"/tests/*.txt)
        result=FAIL
        rc=2
    else
        msg=ok
        if [ $B -gt 0 ]; then
            result=PROVISIONAL
            rc=1
        else
            result=PASS
            rc=0
        fi
    fi

    echo "$msg"
    echo "Files=$f, Tests=$P/$t, Todo=$T, Fixed=$B, Skipped=$S, $d wallclock secs"
    echo "Result: $result"
    rm -rf "$P6_TEST_DIR"
    return $rc
}

######################################################################
#<
#
# Function: p6_test_harness___results(name, duration, prcnt_passed, passed, total, bonus, todo, skipped)
#
#  Args:
#	name -
#	duration -
#	prcnt_passed -
#	passed -
#	total -
#	bonus -
#	todo -
#	skipped -
#
#>
######################################################################
p6_test_harness___results() {
    local name="$1"
    local duration="$2"
    local prcnt_passed="$3"
    local passed="$4"
    local total="$5"
    local bonus="$6"
    local todo="$7"
    local skipped="$8"

    local len=${#name}

    local line=$name
    local i=$len
    while [ "$i" -lt 48 ]; do
        line="$line."
        i=$(($i + 1))
    done

    passed=$(p6_test_harness__zero_lpad "3" "$passed")
    total=$(p6_test_harness__zero_lpad "3" "$total")

    line="$line ${duration}s $passed/$total $prcnt_passed%"
    if [ "$bonus" -gt 0 ]; then
        line="$line [$bonus now pass]"
    else
        if [ "$todo" -gt 0 ]; then
            line="$line, todo=$todo"
        fi
    fi
    if [ "$skipped" -gt 0 ]; then
        line="$line, skipped=$skipped"
    fi

    local color
    if [ "$passed" -eq "$total" ]; then
        if [ "$bonus" -gt 0 ]; then
            color=yellow
        else
            color=green
        fi
    else
        color=red
    fi
    p6_test_colorize__say "$color" "black" "$line"
}

######################################################################
#<
#
# Function: p6_test_harness__zero_lpad(len, str)
#
#  Args:
#	len -
#	str -
#
#>
######################################################################
p6_test_harness__zero_lpad() {
    local len="$1"
    local str="$2"

    local str_len=${#str}

    local i=$str_len
    while [ "$i" -lt $len ]; do
        str="0$str"
        i=$(($i + 1))
    done

    echo "$str"
}

# --------------------------------------------------------------------------------------------------------

p6_test_harness_test_run() {
    local file="$1"
}

p6_test_harness_tests_run() {
    local dir="$1"

    for file in $(
        cd "$dir" || exit 0
        ls -1
    ); do
        p6_test_harness_test_run "$dir/$file" >>"/tmp/$file.txt"
    done
}

p6_test_harness___results() {
    local file="$1"

    # read file
    local name="$1"
    local duration="$2"
    local prcnt_passed="$3"
    local passed="$4"
    local total="$5"
    local bonus="$6"
    local todo="$7"
    local skipped="$8"

    local len=${#name}

    local line=$name
    local i=$len
    while [ "$i" -lt 48 ]; do
        line="$line."
        i=$(p6_test__math_inc "$i")
    done

    passed=$(p6_test_harness__zero_lpad "3" "$passed")
    total=$(p6_test_harness__zero_lpad "3" "$total")

    line="$line ${duration}s $passed/$total $prcnt_passed%"
    if [ "$bonus" -gt 0 ]; then
        line="$line [$bonus now pass]"
    else
        if [ "$todo" -gt 0 ]; then
            line="$line, todo=$todo"
        fi
    fi
    if [ "$skipped" -gt 0 ]; then
        line="$line, skipped=$skipped"
    fi

    local color
    if [ "$passed" -eq "$total" ]; then
        if [ "$bonus" -gt 0 ]; then
            color=yellow
        else
            color=green
        fi
    else
        color=red
    fi
    p6_test_colorize__say "$color" "black" "$line"

}

p6_test_harness__zero_lpad() {
    local len="$1"
    local str="$2"

    local str_len=${#str}

    local i=$str_len
    while [ "$i" -lt $len ]; do
        str="0$str"
        i=$(($i + 1))
    done

    echo "$str"
}
