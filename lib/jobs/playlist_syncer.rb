require 'models/user'
require 'jobs/api_fetch/user_favorites_syncer'
require 'jobs/base_job'

module Smoothie
  class PlaylistSyncer < Smoothie::BaseJob

    def init(id)
      @user = Smoothie::User.new(id)
    end

    def ready?
      @user.synced? && @user.favorites_synced?
    end

    def do_perform
      # Ensure the favorites ids are synced
      wait_for :class => ApiFetch::UserFavoritesSyncer, :args => @user.id
    end

  end
end