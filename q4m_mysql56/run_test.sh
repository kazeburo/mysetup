#!/bin/sh
set -e

yum -y install perl-Test-Simple perl-DBI perl-DBD-mysql perl-Time-HiRes
curl -L http://cpanmin.us/ | perl - -n Parallel::ForkManager Data::Compare Test::mysqld List::MoreUtils
export DBI="dbi:mysql:database=test;host=127.0.0.1;port=13306"
export MYSQL_DIR=/usr/local/q4m
cd /usr/local/src/mysql-$(/usr/local/q4m/bin/mysql --version |perl -nle 'm!Distrib ([0-9\.]+)! and print $1')/storage/q4m
perl run_tests.pl


