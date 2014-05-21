gw-sufia
========

GWU Self-Deposit

This is the repository for the George Washington University Libraries Sufia instance.


Installation
------------

* Install ubuntu package dependencies:
        
        % sudo apt-get install git postgresql libpq-dev redis-server

* Install RVM

        % curl -L https://get.rvm.io | bash -s stable
        % source ~/.rvm/scripts/rvm
        % rvm install ruby-2.1.1
        
       
* Get the gw-sufia code:

        % git clone https://github.com/gwu-libraries/gw-sufia.git
        
* Run the sufia generator:

        % cd gw-sufia
        % rails g sufia -f
        
* Run the migrations

        % rake db:migrate



        
