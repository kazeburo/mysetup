# install MySQL 5.6 and Q4M

## install

    $ sudo sh ./setup.sh

This script builds mysql and q4m and installs to /usr/local/q4m. And installs a init.d script.

## run 

    $ sudo service q4m start

# test with vagrant

    $ vagrant plugin install vagrant-destroy-provisioner
    $ vagrant up

