require 'models/user'
require 'soundcloud_client'
require 'jobs/base_job'

module Smoothie
  module ApiFetch
    class UserSyncer < Smoothie::BaseJob

      def init(id)
        @user = Smoothie::User.new(id)
      end


      def ready?
        @user.synced?
      end


      def do_perform
        soundcloud = Smoothie::SoundcloudClient.new

        # Get the user attributes
        user_data = soundcloud.get_user(@user.id)

        # Save them
        [:tracks_count].each do |attribute|
          @user.send(:"#{attribute}=", user_data[attribute])
        end

        # Updated the synced_at time
        @user.set_synced!
      end

    end
  end
end