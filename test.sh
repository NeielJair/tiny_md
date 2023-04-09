#!/bin/bash

compiler=gcc
perf_times=4
perf_flags=
logs_dir=logs
while getopts c:l:n:p: opt; do
    case $opt in 
        c) compiler=$OPTARG ;;
        l) logs_dir=$OPTARG ;;
        n) perf_times=$OPTARG ;;
        p) perf_flags=$OPTARG ;;
       \?) echo "Unknown option -$OPTARG"; exit 1;;
    esac
done
shift $(( OPTIND - 1 ))

function run_perf () {
    # $1 iter name
    perf stat -r $perf_times $perf_flags ./tiny_md > $logs_dir/$(echo $1)_output.log 2> $logs_dir/$(echo $1)_stat.log

    perf record ./tiny_md
    perf report &> $logs_dir/$(echo $1)_report.log
}

echo "** PERF TIMES: $perf_times **"
mkdir $logs_dir
rm $logs_dir/*.log
echo ""


echo "-- $compiler O0"
make clean
make CC="$compiler" CFLAGS=-O0
echo "- Running perf"
run_perf "O0"
echo ""

echo "-- $compiler O1"
make clean
make CC="$compiler" CFLAGS=-O1
echo "- Running perf"
run_perf "O1"
echo ""

echo "-- $compiler O1 ffast-math"
make clean
make CC="$compiler" CFLAGS="-O1 -ffast-math"
echo "- Running perf"
run_perf "O1_ffastmath"
echo ""

echo "-- $compiler O2"
make clean
make CC="$compiler" CFLAGS=-O2
echo "- Running perf"
run_perf "O2"
echo ""

echo "-- $compiler O3"
make clean
make CC="$compiler" CFLAGS=-O3
echo "- Running perf"
run_perf "O3"
echo ""
