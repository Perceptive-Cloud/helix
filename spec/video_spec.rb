require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Video do
  let(:klass) { Helix::Video }

  subject { klass }
  its(:ancestors) { should include(Helix::Base) }
  its(:guid_name) { should eq('video_id') }
  its(:media_type_sym)    { should be(:video)   }
  its(:plural_media_type) { should eq('videos') }

  describe "Constants"

  describe "an instance" do
    let(:obj) { klass.new({'video_id' => 'some_video_guid'}) }
    subject { obj }
    its(:media_type_sym) { should be(:video) }
  end

end
