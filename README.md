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

### Configure Contact form emailing

  In order to enable the contact form page to send email when the user clicks Send,
set the following properties in config/initializers/sufia.rb :
  * config.action_mailer.contact_email
  * config.action_mailer.from_email

Copy config/initializers/setup_mail.rb.template to config/initializers/setup_mail.rb .
Set the SMTP credentials for the user as whom the app will send email.

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

# ---------------------
# Production Deployment
# ---------------------

The following documentation has been adapted from the work of: https://github.com/curationexperts/hydradam/wiki/Production-Installation%3A-Overview to describe a deployment of the gw-sufia hydra implementaiton.

### System Requirements
A Virtual Server (VM) or Machine with at least:
  1.   64-bit architecture
  1.   15G of memory
  1.   10G of disk space on the root drive
  1.   30-300G of disk space on a drive mounted at /opt, depending on the files you plan to ingest - low end for images/text, high end for audio/video

### Software Requirements
Ubuntu, Version 12.04 Its (Precise Pangolin)[ubuntu-12.04.3-server-amd64.iso](http://releases.ubuntu.com/precise/).

### Steps
1. Use bash as your shell.  
2. Make sure your user has full sudo privileges (with or without password).   
3. Check to be sure that your environment contains a $USER variable.  
`echo $USER` should return your current user name.  
4. Set a $HYDRA_NAME variable to be the name of this hydra head, Sufia.
`echo "HYDRA_NAME=sufia" | sudo tee -a /etc/environment`  
and load it into your shell environment  
`source /etc/environment`  
5. Set the rails environment ($RAILS_ENV) to production  
`echo "RAILS_ENV=production" | sudo tee -a /etc/environment`  
and load that into your shell environment  
`source /etc/environment`  
6. Create the /opt/install directory  
```bash
sudo chown $USER:$USER /opt  
mkdir -p /opt/install
```

### Verification Steps
`echo $USER` should return your current user name  
`echo $HYDRA_NAME` should return "sufia"  
`echo $RAILS_ENV` should return "production"

### Notes
These libraries provide the tools you need to download, compile, and configure packages required by Sufia.

### Steps
1. Install the following development tools & libraries for the Sufia project using your package manager (apt-get). 

Ubuntu:

```shell
sudo apt-get update && sudo apt-get install build-essential git git-core curl openssl libreadline6 libreadline6-dev zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config libmagickwand-dev imagemagick libcurl4-openssl-dev apache2-prefork-dev libxvidcore-dev postgresql libpq-dev redis-server unzip nodejs clamav-daemon openjdk-7-jdk tomcat7 ruby-bundler apache2-mpm-worker
```
### Notes
Ruby is the language of Sufia. Rubygems gives you access to the gems (dependencies, aka other people's code) Sufia needs.

### Steps
Ruby:  
Especially on Ubuntu machines, Ruby 2.0 may be preinstalled. To verify which is installed, enter the command `which ruby` in the terminal window. This should return _/usr/local/bin/ruby_. Additionally, entering `ruby -v` should return _ruby 2.0.0-p353_.  

If you don't have Ruby 2.1.x installed, install it from source by copying and pasting the block of text below:  
```bash
cd /opt/install
wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz  
tar xvzf ruby-2.1.2.tar.gz  
cd ruby-2.1.2
./configure  
make  
sudo make install  
cd /opt
```  

### Verification Steps
You must have Ruby version 2.0.x and Rubygems version 2.x installed to complete the rest of the instructions. To verify that the correct versions are installed, use the following commands.  

1. `which ruby`  
    The system should return _/usr/local/bin/ruby_  

2. `ruby -v`  
    The system should return _ruby 2.0.0p353 (2013-11-22 revision 43784) [x86_64-linux]_  

3. `which gem`  
    The system should return _/usr/local/bin/gem_  

4. `gem -v`  
    The system should return _2.0.14_ 
    # Notes

### Notes
The Java 7 runtime environment is required to run Tomcat, Fedora, and Solr.  

### Steps
1. Verify that Java 7 is installed by entering the command `which java` in the terminal window. This should return _/usr/bin/java_. Additionally, entering `java -version` should return _java version 1.7.x_. If Java 7 is installed, proceed to Step 3.  

2. You now need to configure your machine to use Java 7. Enter the command `sudo update-alternatives --config java` in the terminal window. You will see all available versions of Java. Select Java 7. The final output should look similar to this:  
  
   _There is 1 program that provides 'java'._  

   _Selection    Command_  
   _-----------------------------------------------_  
   _*+ 1           /usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java_  

   _Enter to keep the current selection[+], or type selection number: 1_  

### Verification Steps
Enter the command `java -version` in the terminal window. This should return _java version 1.7.x_.

### Notes
Tomcat is the Java servlet that runs Fedora and Solr.

### Steps  
1. Add the username you're using to install things to the tomcat group, by entering the following commands in the terminal window:  
   Ubuntu: `sudo usermod -G tomcat7 -a $USER`  
2. Exit the terminal window and log back in to make sure the group changes take effect.  
3. (Re)Start your tomcat server, using the following commands:  
   Ubuntu: `sudo service tomcat7 restart`  
   The output should look like this:  
   *Stopping tomcat7:    [  OK  ]*  
   *Starting tomcat7:    [  OK  ]*  

### Verification Steps
1. Test your tomcat installation by browsing to http://localhost:8080 or enter the command `curl localhost:8080` in the terminal window. You should see the default tomcat home page, announcing that "It Works!"
2. Test your group membership to be sure it includes the tomcat or tomcat7 group. Enter the command `id` in the terminal window. The output should look like this:  
*uid=500(user_name) gid=500(user_name) groups=500(user_name),91(tomcat),502(ssh)*  *context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023*  
   **Do not continue until your group membership is updated!**  

### Notes
Create two postgresql users (e.g. fedoradbadmin & sufiadbadmin) and two databases (e.g. fedora3 & sufia_prod)

### Steps
        % sudo su - postgres
        (postgres)% psql
        postgres=# create user YOURSFMDBUSERNAME with createdb password 'YOURSFMDBPASSWORD';
        CREATE ROLE
        postgres=# \q
        (postgres)% createdb -O YOURSFMDBUSERNAME YOURPRODDBNAME
        (postgres)% exit

### Notes
Fedora stores the metadata and preservation information for objects your users will upload to Sufia.

### Steps
Note: You must have completed the installation of the SQL database before you can install Fedora.

1. Ensure that the permissions on /opt are set correctly before you try to install Fedora by entering the command `sudo chown $USER:$USER /opt` in the terminal window.  

2. Set the environment variables for Fedora by entering the commands below in the terminal window.
   ```shell  
   grep -q '^FEDORA_HOME=' /etc/environment || echo "FEDORA_HOME=/opt/fedora" | sudo tee -a /etc/environment  
   echo "PATH=$PATH:$FEDORA_HOME/server/bin:$FEDORA_HOME/client/bin" | sudo tee -a /etc/profile.d/fedora.sh  
   ```
  
3. Log out and log back in to reload environment.  

4. Make sure your path is updated, by entering the command `echo $PATH`.  
   The output should look like this: */usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/fedora/server/bin:/opt/fedora/client/bin:/home/your_username/bin*.  

5. Change to the install directory by entering the command `cd /opt/install`.
  
6. Get the Fedora 3.7.1 installer by entering the command `wget http://downloads.sourceforge.net/project/fedora-commons/fedora/3.7.1/fcrepo-installer-3.7.1.jar`.  
 
7. Run the Fedora installer by entering the command `java -jar fcrepo-installer-3.7.1.jar`. If you make a mistake, you can exit the installer by typing “CANCEL” at any prompt. 

   The installer prompts you to answer several questions. The answers you should give are shown behind the ==> below. When an answer begins with *(default)*, you can just press Enter to accept that as the response and the installer will prompt you for the next response.
   ```text  
   Installation type
   -----------------
   Enter a value ==> custom  
   ```
   ```text  
   Fedora home directory
   -----------------
   Enter a value [default is /opt/fedora] ==> /opt/fedora  
   ```  
   ```text  
   Fedora administrator password  
   -----------------  
   Enter a value Enter a value ==> <somepassword>    
   ```  
   ```text
   Fedora server host  
   -----------------  
   Enter a value [default is localhost] ==> localhost
   ```  
   ```text
   Fedora application server context   
   -----------------  
   Enter a value [default is fedora] ==> fedora  
   ```  
    ```text
   Authentication requirement for API-A   
   -----------------  
   Enter a value [default is false] ==> false  
   ```  
    ```text
   SSL availability     
   -----------------  
   Enter a value [default is false] ==> false   
   ```  
    ```text
   Servlet engine       
   -----------------  
   Enter a value [default is included] ==> existingTomcat  
   ```  
    ```text
   Tomcat home directory  
   -----------------  
   (Ubuntu) Enter a value ==> /var/lib/tomcat7
   ```  
    ```text
   Tomcat HTTP port  
   -----------------  
   Enter a value [default is 8080] ==> 8080  
   ```  
    ```text
   Tomcat shutdown port    
   -----------------  
   Enter a value [default is 8005] ==> 8005  
   ```  
   ```text
   Database  
   -----------------  
   Enter a value ==> postgresql  
   ```  
   ```text
   PostgreSQL JDBC driver    
   -----------------  
   Enter a value [default is included] ==> included  
   ```  
   ```text
   Database username  
   -----------------  
   Enter a value ==> fedoradbadmin   
   ```  
   ```text
   Database password  
   -----------------  
   Enter a value ==> <somepassword>  
   ```  
   ```text
   JDBC URL    
   -----------------  
   Enter a value [default is jdbc:postgresql://localhost/fedora3?useUnicode=true&amp;characterEncoding=UTF-8&amp;autoReconnect=true] ==> 
   jdbc:postgresql://localhost/fedora3?useUnicode=true&amp;characterEncoding=UTF-8&amp;autoReconnect=true    
   ```  
   ```text
   JDBC DriverClass  
   -----------------  
   Enter a value [default is org.postgresql.jdbc.Driver] ==> org.postgresql.jdbc.Driver  
   ```  
   ```text
   Use upstream HTTP authentication (Experimental Feature)  
   -----------------  
   Enter a value [default is false] ==> false  
   ```  
   ```text
   Enable FeSL AuthZ (Experimental Feature)    
   -----------------  
   Enter a value [default is false] ==> false  
   ```  
   ```text
   Policy enforcement enabled      
   -----------------  
   Enter a value [default is false] ==> false  
   ```    
   ```text
   Low Level Storage      
   -----------------  
   Enter a value [default is akubra-fs] ==> akubra-fs  
   ```    
   ```text   
   Enable Resource Index  
   -----------------  
   Enter a value [default is false] ==> false    
   ```  
    ```text   
   Enable Messaging  
   -----------------  
   Enter a value [default is false] ==> false    
   ```  
    ```text   
   Deploy local services and demos
   -----------------  
   Enter a value [default is true] ==> true    
   ```  

8. Give the tomcat user ownership of /opt/fedora, by entering the command  
(Ubuntu) `sudo chown -R tomcat7:tomcat7 /opt/fedora`  

9. Restart tomcat, by entering the command    
(Ubuntu) `sudo service tomcat7 restart`  
and give fedora a good minute or two to get started before you completing the verification steps below.

### Verification Steps
1. To check fedora navigate to http://localhost:8080/fedora or enter the command `curl localhost:8080/fedora/describe` in the terminal window. You should see the address for the default fedora page (which should look similar to this: http://localhost:8080/fedora) in the output.  

### Notes
Solr indexes the content and metadata of your Sufia for quick and easy searching.

### Steps
We recommend installing all the components of the project in the directory /opt and as a result these instructions are designed to be copy/paste. However, if you want to name your project something other than 'Sufia' you'll need to make appropriate changes in steps 4 and 12. These instructions have been tested with solr 4.2 and may or may not work with later versions.

**All commands are run in a terminal window unless otherwise specified.**

1. Change the directory to the install directory.
  ```bash
  cd /opt/install
  ```

2. Download solr 4.8.1.
  ```bash
  wget http://mirrors.sonic.net/apache/lucene/solr/4.8.1/solr-4.8.1.tgz
  ```

3. Unpack the tarball.
  ```bash
  tar xvzf solr-4.8.1.tgz
  ```

4. Double-check that your `$HYDRA_NAME` variable is set correctly.
  ```bash
  echo $HYDRA_NAME
  # should output "sufia"
  ```

5. Create the solr project directories.
  ```bash
  mkdir /opt/solr /opt/solr/$HYDRA_NAME /opt/solr/$HYDRA_NAME/lib
  ```

6. Put the solr `.war` file in the main project directory
  ```bash
  cp ./solr-4.8.1/dist/solr-4.8.1.war /opt/solr/$HYDRA_NAME
  ```

7. Copy the necessary java archives to the library
  ```bash
  sudo cp ./solr-4.8.1/dist/*.jar /opt/solr/$HYDRA_NAME/lib
  ```

8. Copy the `contrib` subdirectory.
  ```bash
  sudo cp -r ./solr-4.8.1/contrib /opt/solr/$HYDRA_NAME/lib
  ```

9. Copy the sample `collection1` directory to production.
  ```bash
  sudo cp -r ./solr-4.8.1/example/solr/collection1 /opt/solr/$HYDRA_NAME/collection1
  ```

10. Copy the English stopwords up a level.
  ```bash
  sudo cp /opt/solr/$HYDRA_NAME/collection1/conf/lang/stopwords_en.txt /opt/solr/$HYDRA_NAME/collection1/conf/
  ```

11. Create the project xml file. 
  ```
  cat > /opt/solr/$HYDRA_NAME/$HYDRA_NAME.xml <<EOF
 <?xml version="1.0" encoding="utf-8"?>  
<Context docBase="/opt/solr/sufia/solr-4.8.1.war" debug="0" crossContext="true">  
    <Environment name="solr/home" type="java.lang.String" value="/opt/solr/sufia" override="true"/>  
</Context>
  EOF
  ```  

12. Give the tomcat user ownership of /opt/solr.
  ```bash
  # If you are using Ubuntu, use this command.
  sudo chown -R tomcat7:tomcat7 /opt/solr
  ``` 
13. Link tomcat to the project xml file.
  ```bash
  # If you using Ubuntu, use this command
  sudo ln -s /opt/solr/$HYDRA_NAME/$HYDRA_NAME.xml /etc/tomcat7/Catalina/localhost/$HYDRA_NAME.xml
  ``` 
14. Solr uses SLF4J for logging, but you need to configure a logging framework yourself. This is required to make Solr run. For example to bind SLF4J to Apache log4j:
  ```bash 
  sudo cp /opt/install/solr-4.8.1/example/lib/ext/* /usr/share/tomcat7/lib
  sudo cp /opt/install/solr-4.8.1/example/resources/log4j.properties /usr/share/tomcat7/lib
  ```
Edit /usr/share/tomcat7/lib/log4j.properties and set solr.log=logs/ to solr.log=/var/log/solr. Next create the log directory and set the proper permissions:
  ```bash 
  sudo mkdir /var/log/solr
  sudo chown tomcat7:tomcat7 /var/log/solr
  ```
Make sure the log will not eat up the entire filesystem and add it to logrotate. Create a file "/etc/logrotate.d/solr" with this content:
  ``` 
/var/log/solr/solr.log {
  copytruncate
  daily
  rotate 5
  compress
  missingok
  create 640 tomcat7 tomcat7
}
  ```
15. Restart tomcat.
   ```bash
   # If you are using Ubuntu, use this command
   sudo service tomcat7 restart 
```  

### Verification Steps
1. Check the solr admin page.
  ```bash
  curl localhost:8080/$HYDRA_NAME/
  ```
  The output should show the html of the solr home page.

### Notes
FITS retrieves xml metadata from the files you upload to Sufia, which allows you to harvest pre-existing metadata such as the file type.

### Steps
1. Change to the install directory.
  
  ```shell
  cd /opt/install
  ```

2. Get FITS.

  ```shell
  wget http://fits.googlecode.com/files/fits-0.6.2.zip
  ```

3. Install `fits.sh`.
   ```shell  
   unzip fits-0.6.2.zip  
   sudo chmod +x fits-0.6.2/fits.sh  
   sudo cp -r fits-0.6.2/* /usr/local/bin/  
   ```

4. Simlink FITS to fits.sh
  ```shell
  sudo ln -s /usr/local/bin/fits.sh /usr/local/bin/fits
  ```

### Verification Steps
1. 
  ```bash   
  fits
  Invalid CLI options
  usage: fits
   -h         print this message
   -i <arg>   input file or directory
   -o <arg>   output file
   -r         process directories recursively when -i is a directory
   -v         print version information
   -x         convert FITS output to a standard metadata schema
   -xc        output using a standard metadata schema and include FITS xml
  ```

### Notes
The Git repository contains the GW-Sufia-specific code. The Gems contain other people's code that we use in GW-Sufials. We are standing on the shoulders of giants here.

### Steps
1. Clone the Git repository and change directories by entering the following commands in the terminal window.
   ```shell    
   cd /opt  
   git clone git://github.com/gwu-libraries/gw-sufia.git ${HYDRA_NAME}  
   cd $HYDRA_NAME  
   ```

2. Confirm that the correct versions of Ruby and RubyGems are installed.  
   1. Enter the command `ruby -v` in the terminal window. This should return 2.0.0.  
   1. Enter the command `gem -v`. This should return 2.0.0 or above.  
   If not, see the [[troubleshooting tips|Troubleshooting Guide]] for instructions on how to update your RubyGems version and/or uninstall the old Ruby version.  

3. Change permissions on the gem directory by entering the command `sudo chown -R $USER:$USER /usr/local/lib/ruby/gems/2.1.0/`.  

4. Install project dependencies for deployment with bundler by entering the command `/usr/local/bin/bundle --deployment`. Note: This may take a while, but you should see the message "Your bundle is complete" at the end.

### Verification Steps
1. Stay in your project home directory (/opt/$HYDRA_NAME) and enter the command `bundle exec rails console production`. You will see an interactive ruby (irb) prompt.
1. Enter the command `Sufia::VERSION`. This should return version 3.5.0 or greater.
1. Type `exit` to return to your regular shell prompt.  

### Notes
The YML files store the confidential information needed to connect the Sufia code to the other elements of the system, including Fedora, Solr, and Redis.

### Steps
You may review the sample .yml files for PostgrSQL, Fedora, Redis, and Solr in the/opt/$HYDRA_NAME/config directory. If you choose to edit them directly, use only the spacebar to create indentation as tabs are not allowed in YML syntax and will trigger a "found token that cannot start any token while scanning for the next token" error.

1. Create a production database.yml file that points to your PostgreSQL database by entering the commands below.
   ```bash
   cp /opt/sufia/config/database.yml.template /opt/sufia/config/database.yml
   ```  
Edit that file accordinly with your settings

2. Create a production fedora.yml file that points to your Fedora by entering the commands below.  
   ```bash
   cat > /opt/$HYDRA_NAME/config/fedora.yml <<EOF
   production:
     user: fedoraAdmin
     password: fedoraAdmin
     url: http://127.0.0.1:8080/fedora
   EOF
   ```  

3. Create a production redis.yml file that points to your Redis server by entering the commands below.  
   ```bash
   cat > /opt/$HYDRA_NAME/config/redis.yml <<EOF
   production:
     host: localhost
     port: 6379
   EOF
   ```  

4. Create a production solr.yml file that points to your Solr by entering the commands below.    
   ```bash
   cat > /opt/$HYDRA_NAME/config/solr.yml << EOF
   production:
     url: http://127.0.0.1:8080/sufia/
   EOF
   ```

### Verification Steps
1. Enter the command `ls -la /opt/$HYDRA_NAME/config` in the terminal window. This should return (among other files) database.yml, fedora.yml, redis.yml, and solr.yml. If you want to view the contents of each file, enter the command `less filename.yml`. To exit and return to the terminal window, type 'q'.  

### Notes
Apache and Passenger work together to serve up the Sufia web pages. Apache is the generic web server and  passenger (https://www.phusionpassenger.com/) manages the multiple processes Sufia (a ruby on rails app) generates.  

### Steps
1. The Apache server should already be installed as part of the Apache development package (one of the [[dependencies|Installation:-Dependencies]]).    

2. (Ubuntu only) Install the passenger gem by entering the command `gem install passenger`.

3. Install passenger’s Apache module by entering the command `passenger-install-apache2-module`.    
   NOTE: if you see a "command not found" error, find the passenger Gem and include the path in your command `/usr/local/lib/ruby/gems/2.0.0/gems/passenger-4.0.37/bin/passenger-install-apache2-module`. Parts of this path may be different depending on the configuration of your system.  

4. Follow the installer prompts - you'll need two sections of the final output for the next two steps. The final output should look similar to this.

   *[your_Username@ip sufia]$ passenger-install-apache2-module*  
   *Welcome to the Phusion Passenger Apache 2 module installer, v4.0.37.*  

   *...*  
   *Don't worry if anything goes wrong. This installer will advise you on how to*  
   *solve any problems.*   

   *Press Enter to continue, or Ctrl-C to abort.*   

   *--------------------------------------------*  

   *Which languages are you interested in?*  

   *Use <space> to select.*  
   *If the menu doesn't display correctly, ensure that your terminal supports UTF-8.*  

   * ‣ ⬢   Ruby*  
   *⬡ Python*  
   *⬢  Node.js*  
   *⬢   Meteor*  

   *--------------------------------------------*  

   *Checking for required software...*  
   *...*  
   *Sanity checking Apache installation...*  
   *All good!*  
   *...*
   *linking shared-object passenger_native_support.so*

   *--------------------------------------------*  
   *Almost there!*   

   *Please edit your Apache configuration file, and add these lines:*  

 LoadModule passenger_module /usr/local/lib/ruby/gems/2.1.0/gems/passenger-4.0.45/buildout/apache2/mod_passenger.so
   <IfModule mod_passenger.c>
     PassengerRoot /usr/local/lib/ruby/gems/2.1.0/gems/passenger-4.0.45
     PassengerDefaultRuby /usr/local/bin/ruby
   </IfModule>

   *After you restart Apache, you are ready to deploy any number of web*  
   *applications on Apache, with a minimum amount of configuration!*  

   *Press ENTER to continue.*  
   *...*  
   *And that's it! You may also want to check the Users Guide for security and*  
   *optimization tips, troubleshooting and other useful information:*  

   /usr/local/lib/ruby/gems/2.1.0/gems/passenger-4.0.45/doc/Users guide Apache.html
  https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html

5. When the installer is done, create the passenger configuration file using the steps below.  
   1. Begin the command to create the passenger.conf file by entering `sudo tee -a /etc/apache2/conf.d/passenger.conf <<EOF` in the terminal window. The computer is waiting for more input and will respond with the prompt `>`.

   1. Copy the text that begins "LoadModule" from the passenger output and paste it in at the prompt. As an example, the text below was copied from the output example in Step 5.
     ```text
   LoadModule passenger_module /usr/local/lib/ruby/gems/2.1.0/gems/passenger-4.0.45/buildout/apache2/mod_passenger.so
   <IfModule mod_passenger.c>
     PassengerRoot /usr/local/lib/ruby/gems/2.1.0/gems/passenger-4.0.45
     PassengerDefaultRuby /usr/local/bin/ruby
   </IfModule>
     ```
   1. Add a line to configure the PassengerTempDir by typing `PassengerTempDir /opt/passenger_temp`, as shown below.  
     ```text
     LoadModule passenger_module /usr/local/lib/ruby/gems/2.1.0/gems/passenger-4.0.45/buildout/apache2/mod_passenge$
   <IfModule mod_passenger.c>
     PassengerRoot /usr/local/lib/ruby/gems/2.1.0/gems/passenger-4.0.45
     PassengerDefaultRuby /usr/local/bin/ruby
     PassengerTempDir /opt/passenger_temp
   </IfModule>
     ```

   1. Add `EOF` on its own line and hit enter to create the file. For reference, see the [[sample passenger.conf file|Sample-passenger.conf]]  

6. Create the project configuration file using the steps below.  
   1. Begin the command to create the file by entering `sudo tee -a /etc/apache2/conf.d/$HYDRA_NAME.conf <<EOF` in the terminal window. The computer is waiting for more input and will respond with the prompt `>`

   2. Copy these two lines to begin your configuration file:
      Note: You will need to change www.yourhoust.com to your server's name. For example, www.dcesufia.com or sufia.publictvstation.org and then hit Enter. You will see the `>` prompt again.
      ```
      <VirtualHost *:80>  
      ServerName www.yourhost.com  
      ``` 

      1. Add the rest of the configuration information:  

         ```shell  
         # !!! Be sure to point DocumentRoot to 'public'!  
         # !!! Be sure to point DocumentRoot to 'public'!
      DocumentRoot /opt/sufia/public
      XSendFile on
      XSendFilePath /opt/xsendfile
      <Directory /opt/sufia/public>
         # This relaxes Apache security settings.
         AllowOverride all
         # MultiViews must be turned off.
         Options -MultiViews
         # Uncomment this if you're on Apache >= 2.4:
         #Require all granted
      </Directory>
   </VirtualHost>
         ```  
         and hit Enter. You will see the `>` prompt again.   

   3. Type `EOF` on its own line and hit enter to create the file. For reference, see the [[sample $HYDRA_NAME.conf file|Sample-$HYDRA_NAME.conf]].  

7. Install mod_xsendfile for apache by entering the following commands:  
   ```shell  
   cd /opt/install  
   git clone https://github.com/nmaier/mod_xsendfile.git  
   cd mod_xsendfile  
   sudo apxs2 -cia mod_xsendfile.c  
   ```  

   For more information, see the [xsendfile docs](https://tn123.org/mod_xsendfile/).

8. Create the PassengerTempDir and XSendFile directories referred to in your passenger config by entering the command `mkdir /opt/passenger_temp /opt/xsendfile`.  

### Notes
Configure the Rails Application to make sure that all the parts of the system are working together. This step includes the secret token, the Fits path, Solr configuration, the temporary transcoding directory, storage management, and more.

### Steps
1. Enable the secret token for the site by completing the steps below.  
   1. Generate a string for the secret token by entering the command `cd /opt/$HYDRA_NAME && bundle exec rake secret` in the terminal window.  
   2. Copy /opt/$HYDRA_NAME/config/initializers/secret_token.rb.template to /opt/$HYDRA_NAME/config/initializers/secret_token.rb by entering the command `cp /opt/$HYDRA_NAME/config/initializers/secret_token.rb.template /opt/$HYDRA_NAME/config/initializers/secret_token.rb`.  
   1. Edit `secret_token.rb` and replace the sample string with the string you just generated.  

2. Enable a different secret token for devise (user authentication) by completing the steps below.  
   1. Generate a second string for a different secret token by entering the command `cd /opt/$HYDRA_NAME && export DEVISE_SECRET=$(bundle exec rake secret)`.  
   1. Copy /opt/$HYDRA_NAME/config/initializers/devise.rb.sample to /opt/$HYDRA_NAME/config/initializers/devise.rb `cp /opt/$HYDRA_NAME/config/initializers/devise.rb.sample /opt/$HYDRA_NAME/config/initializers/devise.rb`.  
   1. Replace the sample string with the string you just generated by entering the command `sed -i.bak s/key\ =\ \'.*\'/key\ =\ \'$DEVISE_SECRET\'/g /opt/$HYDRA_NAME/config/initializers/devise.rb`  
 
3. Symlink the solrconfig.xml and schema.xml files from the application into Solr by entering the commands:
   ```shell  
    sudo ln -sf /opt/$HYDRA_NAME/solr_conf/conf/schema.xml /opt/solr/$HYDRA_NAME/collection1/conf/schema.xml  
    sudo ln -sf /opt/$HYDRA_NAME/solr_conf/conf/solrconfig.xml /opt/solr/$HYDRA_NAME/collection1/conf/solrconfig.xml  
    ```  

4. Set the Fits path for sufia by entering the command `sed -i.bak "s/\/home\/ubuntu\/fits-0\.6\.1\/fits\.sh/\/usr\/local\/bin\/fits\.sh/g" /opt/$HYDRA_NAME/config/initializers/sufia.rb`.  

5. Create and configure the temporary directory for transcoding to use the default directory by entering the command `mkdir /opt/sufia_tmp`.  
  To use a different directory name, edit /opt/$HYDRA_NAME/config/initializers/sufia.rb and change the config.temp_file_base setting to your preferred name, then create your directory. The temporary transcoding directory should be owned by $USER.  

6. If you are using the local filesystem for storage, skip this step. The storage manager setting determines what kind of storage hydra expects for your fedora objects. The default setting is "NullStorageManager", which means you're using the local filesystem. If you are using an HSM to store your fedora objects, you must edit /opt/$HYDRA_NAME/config/application.rb and change the config.storage_manager line to `config.storage_manager = 'SamfsStorageManager'`.  

7. Prepare the databases & assets by entering the commands:  
   ```shell  
   cd /opt/$HYDRA_NAME  
   bundle exec rake db:migrate RAILS_ENV=production 
   bundle exec rake assets:precompile RAILS_ENV=production 
   ``` 
8. Make the Apache user own the passenger temp and xsendfile directories using the command  
Ubuntu: `sudo chown www-data:www-data /opt/passenger_temp /opt/xsendfile`  

9. Restart tomcat using the command    
Ubuntu: `sudo service tomcat7 restart`  

10. Restart apache using the command  
Ubuntu: `sudo service apache2 restart`  


### Verification Steps
1. Open a browser and navigate to the home page of your application. You should see the default Sufia home page.

### SSL and Shibboleth Setup
Refer to the following repository for instructions to setup SSL on your server and confgure Shibboleth Service Provider daemon: https://github.com/gwu-libraries/shibboleth

### GW Sufia Shibboleth Settings
   ```shell
   nano /config/environments/production.rb
   ```

Uncomment and edit the following with your Shibboleth login/logout URLS:

   ```shell
  #  config.logout_url = "https://example.com/Shibboleth.sso/Logout"
  #  config.login_url = "https://example.com/users/auth/shibboleth"
  ```
