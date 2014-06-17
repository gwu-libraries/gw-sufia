gw-sufia [![Build Status](https://travis-ci.org/gwu-libraries/gw-sufia.png?branch=master)](https://travis-ci.org/gwu-libraries/gw-sufia)
========

GWU Self-Deposit

This is the repository for the George Washington University Libraries Sufia instance.


Installation
------------

### Dependencies

* Install ubuntu package dependencies:
        
        % sudo apt-get update
        % sudo apt-get install git postgresql libpq-dev redis-server nodejs unzip openjdk-6-jre clamav-daemon curl

* Install RVM

        % curl -L https://get.rvm.io | bash -s stable
        % source ~/.rvm/scripts/rvm
        % rvm install ruby-2.1.1
        

### Install

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

* Run the migrations

        % rake db:migrate

* Get a copy of hydra-jetty

        % rake jetty:clean
        % rake jetty:config
        % rake jetty:start

* Generate certificate files and keys for SSL

        Create a new folder for your ssl certs & keys
        % mkdir .ssl
        % cd .ssl
        Generate a new server key with a password
        % openssl genrsa -des3 -out server.key 2048
        Create an insecure server key without a password
        % openssl rsa -in server.key -out server.key.insecure
        Replace your secure server key with your insecure server key
        % mv server.key server.key.secure
        % mv server.key.insecure server.key
        Create a certificate signing request *In production deployments you should provide this CSR to your cerificate authority to generate a signed certificate*
        % openssl req -new -key server.key -out server.csr *this _may_ require sudo; try first without
        Create a self a signed certificate *Should not be used in production deployments*
        % openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
        
* Start your thin server

        % cd ..
        % thin start -p <port number> --ssl --ssl-key-file .ssl/server.key --ssl-cert-file .ssl/server.crt
        
* Verify that it's running

        % rails s -p <port number>

  And browse to the URL

### Next: Google Analytics

  In _config/initializers/sufia.rb_, edit the config.analytics property to true:

        config.analytics = true

  Also in _config/initializers/sufia.rb_, uncomment config.google_analytics_id and set its value.  The value will typically be of the form _UA-12345678-1_.

  Copy _config/analytics.yml.template_ to _config/analytics.yml_:

        % cd config
        % cp analytics.yml.template analytics.yml

  Edit _config/analytics.yml_ - uncomment all lines starting with "analytics:"
and populate the values with the OAuth values provided for the project in the
Google Developers console.  See the README at https://github.com/projecthydra/sufia for additional guidance on setting up the project with Google Analytics
(however, you do _not_ need to run the sufia:models:usagestats generator).

Additionally, once you create the client ID and google generates a client email address, go to the google analytics admin page, select the account, click on User Management, add the client email address and grant it Read & Analyze permissions.  (See https://support.google.com/analytics/answer/1009702?hl=en for more information)

### Next: Browse-everything

  Copy config/browse_everything_providers.yml.template to config/browse_everything_providers.yml
  and populate with application keys required by each provider.

        % cd config
        % cp browse_everything_providers.yml.template browse_everything_providers.yml

  and edit browse_everything_providers.yml .  As noted at the browse-everything repo (https://github.com/projecthydra-labs/browse-everything/wiki/Configuring-browse-everything), you must register your application
with each cloud provider separately:

    * Skydrive: https://account.live.com/developers/applications/create
    * Dropbox: https://www.dropbox.com/developers/apps/create
    * Box: https://app.box.com/developers/services/edit/
    * GoogleDrive: https://code.google.com/apis/console

  Note that the application must be configured with each of the above providers with a redirect URI of:
  
         https://<MY SERVER URL>:<PORT>/browse/connect

  Add this line to config/initializers/sufia.rb:

         config.browse_everything = BrowseEverything.config

### Install fits.sh

  Go to http://code.google.com/p/fits/downloads/list and download a copy of fits to /usr/local/bin, and unpack it.
  
        % cd /usr/local/bin
        % wget https://fits.googlecode.com/files/fits-0.6.2.zip
        % unzip fits-0.6.2.zip

  Add execute permissions to fits.sh
  
        % cd fits-0.6.2
        % sudo chmod a+x fits.sh
        
   In config/initializers/sufia.rb, uncomment the line with config.fits_path and add your fits location:
   
        config.fits_path = "/usr/local/bin/fits-0.6.2/fits.sh"

### Start a Redis RESQUE pool

  Run the included script to start a RESQUE pool for either the "production" or "development" environment.
  
        % RAILS_ENV=development rake resque:workers COUNT=3 QUEUE=* VERBOSE=1

# Admin Users

As a stopgap with the current rudimentary implementation of user groups, to make an admin user with id USERID do the following:

```ruby
user = User.find(USERID)
user.group_list = "registered;?;admin"
user.save
```
