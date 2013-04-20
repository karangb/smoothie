require 'spec_helper'

require 'api_fetch/user_syncer'

describe Smoothie::ApiFetch::UserSyncer do

  let(:user_id){2339203}
  let(:syncer){Smoothie::ApiFetch::UserSyncer.new('id' => user_id)}

  describe "#run" do

    it "should work" do
      user = Smoothie::User.new(user_id)

      user.synced?.should be_false

      syncer.run

      user.synced?.should be_true

      user.username.value.should      == "MrRuru"
      user.url.value.should           == "http://soundcloud.com/mrruru"
      user.tracks_count.value.should  == "474"
    end

  end
 
end