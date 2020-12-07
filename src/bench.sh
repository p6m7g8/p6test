# shellcheck shell=bash
######################################################################
#<
#
# Function: p6_test_bench(times, thing)
#
#  Args:
#	times -
#	thing -
#
#>
######################################################################
p6_test_bench() {
    local times="$1"
    local thing="$2"

    echo "1..$times"

    local d=0

    local m=0
    local M=0
    local i=$times

    local data=
    while [ "$i" -gt 0 ]; do
        local vals
        vals=$(p6_test_harness_test_run "$thing")
        local di
        di=$(echo "$vals" | grep -o 'd=[0-9.\-]*' | sed -e 's,d=,,')
        d=$(p6_test__math_inc "$d" "$di")

        local lt
        lt=$(p6_test__math_lt "$di" "$m")
        local gt
        gt=$(p6_test__math_gt "$di" "$M")

        if [ "$lt" -eq 1 ] || [ "$i" -eq "$times" ]; then
            m=$di
        fi
        if [ "$gt" -eq 1 ]; then
            M=$di
        fi

        data="$data $di"
        i=$(($i - 1))
        echo ".\c"
    done

    local a
    a=$(echo "scale=3; ($d/$times)" | bc -lq)
    local s
    s=$(echo "$data" | tr " " "\n" | awk '$1+0 == $1 { sum+=$1; sumsq+=$1*$1; cnt++ } END { print sumsq/cnt; print sqrt(sumsq/cnt-(sum/cnt)**2) }' | xargs)

    echo
    echo "Avg=${a}s Std=${s}s"
    echo "Min=${m}s Max=${M}s Total=${d}s"
}
