require 'models/track'
require 'soundcloud_client'
require 'jobs/base_job'

module Smoothie
  module ApiFetch
    class TrackSyncer < Smoothie::BaseJob

      def init(id)
        @track = Smoothie::Track.new(id)
      end


      def ready?
        @track.synced?
      end


      def do_perform
        # Core fetching
        soundcloud = Smoothie::SoundcloudClient.new

        # Get the track attributes
        track_data = soundcloud.get_track(@track.id)      

        # Save them
        [:users_count].each do |attribute|
          @track.send(:"#{attribute}=", track_data[attribute])
        end

        # Updating synced_at time
        @track.set_synced!
      end

    end
  end
end