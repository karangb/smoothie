# # Fetches a users's track graph (favorite tracks of users who favorited the same tracks as the first one)
# # Need to sync the tracks / users until the last level, to get their favorites / favoriters count
# require 'chainable_job/base_job'
# require 'playlist_syncer'
# require 'api_fetch/track_favoriters_syncer'
# require 'api_fetch/user_favorites_syncer'
  
module Smoothie
  class TrackGraphSyncer < Smoothie::BaseJob

  	DEFAULT_LIMIT = 10

    def init(id, limit = DEFAULT_LIMIT)
      @user   = Smoothie::User.new(id)
      @limit  = limit
    end

    def ready?
      @user.tracks_graph_synced?
    end


    # Naive implementation, to make recursive when a little more mature
    # Complexity : NxLxL -- N : size of user playlist -- L : limit size
    def do_perform
      # Ensure the user's playlist is synced
      wait_for Smoothie::PlaylistSyncer.new('id' => @user.id)


      # Sync the playlist details (for the users count, AND their favoriters ids)
      user_tracks_ids = @user.track_ids.members # N

      wait_for user_tracks_ids.map{|track_id| 
        [ 
          TrackSyncer.new('id' => track_id), 
          TrackFavoritersSyncer.new('id' => track_id, 'limit' => default_limit)
        ]
      }.flatten


      # Sync the other users details (their favorite count and ids)
      other_favoriters_ids = user_tracks_ids.map{|track_id| Track.new(track_id).user_ids.members}.flatten.uniq

      wait_for other_favoriters_ids.map{|user_id|
        [
          UserSyncer.new('id' => user_id),
          UserFavoritesSyncer.new('id' => user_id, 'limit' => default_limit)
        ]
      }.flatten


      # Sync the deep tracks ids (for their favoriters count)
      deep_track_ids = other_favoriters_ids.map{|user_id|User.new(user_id).track_ids.members}.flatten.uniq

      wait_for deep_track_ids.map{|track_id|
        TrackSyncer.new(track_id)
      }

    end
  end
end
