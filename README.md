gw-sufia
========

GWU Self-Deposit

This is the repository for the George Washington University Libraries Sufia instance.


Installation
------------

* Install ubuntu package dependencies:
        
        % sudo apt-get install git postgresql libpq-dev redis-server nodejs

* Install RVM

        % curl -L https://get.rvm.io | bash -s stable
        % source ~/.rvm/scripts/rvm
        % rvm install ruby-2.1.1
        
       
* Get the gw-sufia code:

        % git clone https://github.com/gwu-libraries/gw-sufia.git
        
* Install gems

        % bundle install
        
* Create a postgresql user and three databases (e.g. sufia_dev, sufia_test, sufia_prod)

        % sudo su - postgres
        (postgres)% psql
        postgres=# create user YOURSFMDBUSERNAME with createdb password 'YOURSFMDBPASSWORD';
        CREATE ROLE
        postgres=# \q
        (postgres)% createdb -O YOURSFMDBUSERNAME YOURDEVDBNAME
        (postgres)% createdb -O YOURSFMDBUSERNAME YOURTESTDBNAME
        (postgres)% createdb -O YOURSFMDBUSERNAME YOURPRODDBNAME
        (postgres)% exit

* Create the database.yml file

        % cd gw-sufia/config
        % cp database.yml.template database.yml
        
        Edit database.yml to add your specific database names and credentials
        
* Run the sufia generator:

        % cd ..
        % rails g sufia -f
        
* Run the migrations

        % rake db:migrate

* Get a copy of hydra-jetty

        % rake jetty:clean
        % rake jetty:config
        % rake jetty:start


        
