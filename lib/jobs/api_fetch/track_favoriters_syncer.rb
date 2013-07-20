require 'models/track'
require 'jobs/api_fetch/track_syncer'
require 'soundcloud_client'
require 'jobs/base_job'

module Smoothie
  module ApiFetch
    class TrackFavoritersSyncer < Smoothie::BaseJob

      def init(id)
        @track = Smoothie::Track.new(id)
      end


      def ready?
        @track.favoriters_up_to_date?
      end


      def do_perform
        # Ensure the track is synced
        wait_for :class => ApiFetch::TrackSyncer, :args => @track.id

        soundcloud = Smoothie::SoundcloudClient.new

        # Get the favoriters ids
        limit = @track.users_count.value.to_i
        favoriter_ids = soundcloud.get_track_favoriters(@track.id, limit)

        # Save them
        unless favoriter_ids.empty?
          @track.user_ids.del
          @track.user_ids << favoriter_ids
        end

        # Updated the synced_at time
        @track.set_favoriters_synced!
      end

    end
  end
end