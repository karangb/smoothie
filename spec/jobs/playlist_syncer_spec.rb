require 'spec_helper'
require 'jobs/playlist_syncer'

describe Smoothie::PlaylistSyncer do

  let(:user_id){3207}

  describe "#run" do

    it "should call the user favorites syncer" do

      user = Smoothie::User.new(user_id)
      user.favorites_synced?.should be_false

      Smoothie::PlaylistSyncer.new.perform(user_id)

      Smoothie::ApiFetch::UserFavoritesSyncer.jobs.count.should == 1
      Smoothie::ApiFetch::UserFavoritesSyncer.jobs.first["args"].should == [user_id]

    end

  end
 
end