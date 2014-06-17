class Ability
  include Hydra::Ability
  include Sufia::Ability

  def featured_work_abilities
    can [:create, :destroy, :update], FeaturedWork if admin_user?
  end

  def editor_abilities
    if admin_user?
      can :create, TinymceAsset
      can :update, ContentBlock
    end
  end

  def stats_abilities
    alias_action :stats, to: :read
  end

  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end
  end

  private

  # TODO: Point this at the right group (perhaps something stored in LDAP?)
  def admin_user?
    user_groups.include? 'registered'
  end
end
