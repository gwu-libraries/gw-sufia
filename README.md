gw-sufia
========

GWU Self-Deposit

This is the repository for the George Washington University Libraries Sufia instance.


Installation
------------

* Install ubuntu package dependencies:
        
        % sudo apt-get update
        % sudo apt-get install git postgresql libpq-dev redis-server nodejs unzip openjdk-6-jre clamav-daemon curl

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

* Create a secret_token.rb file and generate its secret token

        % cd initializers
        % cp secret_token.rb.template secret_token.rb
        % rake gw-sufia:generate_secret
        
* Run the sufia generator:

        % cd ../..
        % rails g sufia -f
        
        Answer 'n' (no) when prompted whether to overwrite files.
        
* Edit config/routes.rb to match the file in the git repo (rails generate seems to overwrite it)
        
* Run the migrations

        % rake db:migrate

* Get a copy of hydra-jetty

        % rake jetty:clean
        % rake jetty:config
        % rake jetty:start
        
* Verify that it's running

        % rails s -p <port number>

  And browse to the URL

* Next: Google Analytics

* Next: Browse-everything

* Install fits.sh

  Go to http://code.google.com/p/fits/downloads/list and download a copy of fits to /usr/local/bin, and unpack it.
  
        % cd /usr/local/bin
        % curl 'https://fits.googlecode.com/files/fits-0.6.2.zip' >> fits-0.6.2.zip
        % unzip fits-0.6.2.zip

  Add execute permissions to fits.sh
  
        % cd fits-0.6.2.zip
        % sudo chmod a+x fits.sh
        
   In config/initializers/sufia.rb, uncomment the line with config.fits_path and add your fits location:
   
        config.fits_path = "/usr/local/bin/fits-0.6.2/fits.sh"


        
