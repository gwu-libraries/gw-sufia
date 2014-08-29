class User < ActiveRecord::Base
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Sufia behaviors.
  include Sufia::User

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :omniauthable, :omniauth_providers => [:shibboleth]

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end
  
  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_create do |user|
      user.email = auth[:info][:email]
      user.display_name = auth[:info][:first_name] + auth[:info][:last_name]
      user.affiliation = auth[:extra][:raw_info][:affiliation]
      user.shibboleth_id = auth[:extra][:raw_info][:"Shib-Session-ID"]
    end
  end
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.shibboleth_data"] && session["devise.shibboleth_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end
end
