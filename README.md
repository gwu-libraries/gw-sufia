gw-sufia [![Build Status](https://travis-ci.org/gwu-libraries/gw-sufia.png?branch=master)](https://travis-ci.org/gwu-libraries/gw-sufia)
========

GWU Self-Deposit

This is the repository for the George Washington University Libraries Sufia instance.

Installation
------------

### Dependencies

* Install ubuntu package dependencies:

        % sudo apt-get update
        % sudo apt-get install git postgresql libpq-dev redis-server nodejs unzip openjdk-6-jre clamav-daemon curl imagemagick libapache2-mod-shib2

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

### Next: Full-text indexing

Use the following rake task to pull the necessary extraction jars into the app:

        % rake sufia:jetty:config

Sufia should handle everything else for you.

### Next: Google Analytics

  If you are using google analytics,

  Copy _config/analytics.yml.template_ to _config/analytics.yml_:

        % cd config
        % cp analytics.yml.template analytics.yml

  Edit _config/analytics.yml_ - populate the values with the google analytics
id (typically of the form _UA-12345678-9_,
and populate the OAuth values provided for the project in the
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

  Dropbox, Box, and Skydrive now require the redirect URI to be HTTPS, not HTTP.

### Install fits.sh

  Go to http://code.google.com/p/fits/downloads/list and download a copy of fits to /usr/local/bin, and unpack it.

        % cd /usr/local/bin
        % wget https://fits.googlecode.com/files/fits-0.6.2.zip
        % unzip fits-0.6.2.zip

  Add execute permissions to fits.sh

        % cd fits-0.6.2
        % sudo chmod a+x fits.sh

* Start a Redis RESQUE pool

  Run the included script to start a RESQUE pool for either the "production" or "development" environment.

        % RAILS_ENV=development rake resque:workers COUNT=3 QUEUE=* VERBOSE=1

### Admin Users

As a stopgap with the current rudimentary implementation of user groups, to make an admin user with id USERID do the following at the rails console:

```ruby
user = User.find(USERID)
user.group_list = "registered;?;admin"
user.save
```

### Run the application

  To run a development server in non-SSL mode:

         % rails s -p <PORT NUMBER>

  To run a development server in SSL mode:

         % thin start -p <PORT NUMBER> --ssl --ssl-key-file <PATH TO YOUR server.key FILE> --ssl-cert-file <PATH TO YOUR server.crt FILE>

# Configure Shibboleth

* Enable the Apache2 Shibboleth module:
  
        % sudo a2enmod shib2

* Generate a x.509 certificate for Shibboleth to use:

        % sudo shib-keygen

* Restart Apache2:
 
        % sudo service apache2 restart
        
* Navigate to https://localhost/Shibboleth.sso/Metadata to download your Service Provider metadata file.  Provide this file to your idP or upload it to testshib.org/register.html for testing.
  
* Connfigure your shibboleth2.xml file or generate a test file from testshib.org/configure.html and upload it your instance.
 
        % sudo vi /etc/shibboleth/shibboleth2.xml

* Configure your attribute-map.xml file to expose the Shibboleth attributes you'd like to use.

        % sudo vi /etc/shibboleth/attribute-map.xml

* Generate self-signed certificates or signed certificates for SSL and configure an SSL vhost.

* Add the following to your SSL vhost file:

        <Location /secure>
         # this Location directive is what redirects apache over to the IdP.
         AuthType shibboleth
         ShibRequestSetting requireSession 1
         require valid-user
        </Location>

        
* Restart Shibd & Apache2:
 
        % sudo service shibd restart
        % sudo service apache2 restart
        
* Verify your Shibboleth service provider installation by navigating to https://localhost/secure
