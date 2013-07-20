require 'spec_helper'
require 'jobs/api_fetch/track_favoriters_syncer'

describe Smoothie::ApiFetch::TrackFavoritersSyncer do

  let(:track_id){87037634}
  let(:track){Smoothie::Track.new(track_id)}
  let(:syncer){Smoothie::ApiFetch::TrackFavoritersSyncer.new}


  describe "#run" do

    it "should fetch the track before" do
      syncer.should_receive(:wait_for).with(:class => Smoothie::ApiFetch::TrackSyncer, :args => track_id)

      VCR.use_cassette("track_favoriters_syncer_#{track_id}") do
        syncer.perform(track_id)
      end
    end

    it "should fetch all the favorites and clear the old ones" do
      track.user_ids << (1..1000).to_a
      track.user_ids.count.should == 1000

      # Simulate an already synced track
      syncer.stub!(:wait_for)
      track.users_count = 16342

      VCR.use_cassette("track_favoriters_syncer_#{track_id}") do
        syncer.perform(track_id)
      end

      track.user_ids.count.should == 7950
    end

    it "should set the favorites synced at timestamp after finishing" do
      track.favoriters_synced_at = Time.now - 10*(24*3600)

      # Simulate an already synced track
      syncer.stub!(:wait_for)

      VCR.use_cassette("track_favoriters_syncer_#{track_id}") do
        syncer.perform(track_id)
      end

      track.favoriters_synced_at.value.should == Time.now.to_s
    end

  end

end