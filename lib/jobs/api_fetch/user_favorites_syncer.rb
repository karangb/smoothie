require 'models/user'
require 'jobs/api_fetch/user_syncer'
require 'soundcloud_client'
require 'jobs/base_job'

module Smoothie
  module ApiFetch
    class UserFavoritesSyncer < Smoothie::BaseJob

      def init(id)
        @user = Smoothie::User.new(id)
      end


      def ready?
        @user.favorites_synced?
      end


      def do_perform
        # Ensure the user is synced
        wait_for ApiFetch::UserSyncer.new('id' => @user.id)

        soundcloud = Smoothie::SoundcloudClient.new

        # Get all the favorites ids
        limit = @user.tracks_count.value.to_i
        favorite_ids = soundcloud.get_user_favorites(@user.id, limit)

        # Set them as the user favorites
        unless favorite_ids.empty?
          @user.track_ids.del
          @user.track_ids.add favorite_ids
        end

        # Updated the synced_at time
        @user.set_favorites_synced!
      end

    end
  end
end