#!/bin/sh
set -e

MYVER=5.6.15
Q4MVER=0.9.11

CDIR=$(cd $(dirname $0) && pwd)
cd /usr/local/src
if [ -f $CDIR/mysql-$MYVER.tar.gz ]; then
    cp $CDIR/mysql-$MYVER.tar.gz ./
fi
if [ ! -f mysql-$MYVER.tar.gz ]; then
    wget http://ftp.jaist.ac.jp/pub/mysql/Downloads/MySQL-5.6/mysql-$MYVER.tar.gz
fi
tar zxf mysql-$MYVER.tar.gz

if [ -d q4m-$Q4MVER ]; then
    rm -rf q4m-$Q4MVER
fi
if [ ! -f q4m-$Q4MVER.tar.gz ]; then
    wget http://q4m.kazuhooku.com/dist/q4m-$Q4MVER.tar.gz
fi
tar zxf q4m-$Q4MVER.tar.gz
mv q4m-$Q4MVER mysql-$MYVER/storage/q4m
if [ ! -f mysql-$MYVER/storage/q4m/CMakeLists.txt ]; then
  curl -kL https://raw.github.com/q4m/q4m/0.9.11/CMakeLists.txt > mysql-$MYVER/storage/q4m/CMakeLists.txt
fi

yum install -y cmake ncurses-devel libaio-devel
cd mysql-$MYVER
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/q4m \
  -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=all \
  -DWITH_ZLIB=bundled -DWITH_SSL=bundled -DWITH_READLINE=1 -DWITH_PIC=ON -DWITH_FAST_MUTEXES=ON \
  -DWITH_DEBUG=OFF \
  -DCOMPILATION_COMMENT="Q4M" -DMYSQL_SERVER_SUFFIX="-q4m" \
  -DMYSQL_USER=nobody -DMYSQL_UNIX_ADDR="/tmp/mysql_q4m.sock" -DMYSQL_TCP_PORT=13306 \
  -DWITH_DEFAULT_FEATURE_SET=xsmall \
  -DWITH_PARTITION_STORAGE_ENGINE=1 \
  -DWITHOUT_DAEMON_EXAMPLE_STORAGE_ENGINE=1 \
  -DWITHOUT_FTEXAMPLE_STORAGE_ENGINE=1 \
  -DWITHOUT_EXAMPLE_STORAGE_ENGINE=1 \
  -DWITHOUT_ARCHIVE_STORAGE_ENGINE=1 \
  -DWITHOUT_BLACKHOLE_STORAGE_ENGINE=1 \
  -DWITHOUT_FEDERATED_STORAGE_ENGINE=1 \
  -DWITHOUT_INNOBASE_STORAGE_ENGINE=1 \
  -DWITHOUT_PERFSCHEMA_STORAGE_ENGINE=1 \
  -DWITHOUT_NDBCLUSTER_STORAGE_ENGINE=1 \
  -DWITH_INNODB_MEMCACHED=OFF \
  -DWITH_EMBEDDED_SERVER=OFF \
  -DWITH_UNIT_TESTS=OFF
make
make install

mkdir -p /usr/local/q4m/etc
cp $CDIR/my.cnf /usr/local/q4m/etc
cp $CDIR/q4m.init /etc/init.d/q4m
chmod 755 /etc/init.d/q4m
chkconfig --add q4m

/usr/local/q4m/scripts/mysql_install_db --skip-name-resolve \
  --basedir=/usr/local/q4m --defaults-file=/usr/local/q4m/etc/my.cnf
rm -f /usr/local/q4m/my.cnf
chmod 755 /usr/local/q4m/var
/etc/init.d/q4m start

cat storage/q4m/support-files/install.sql | /usr/local/q4m/bin/mysql -S /tmp/mysql_q4m.sock
echo "show plugins" | | /usr/local/q4m/bin/mysql -S /tmp/mysql_q4m.sock



