require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Track do
  let(:klass) { Helix::Track }

  subject { klass }
  its(:ancestors) { should include(Helix::Base) }
  its(:guid_name) { should eq('track_id') }
  its(:plural_media_type) { should eq('tracks') }

  describe "Constants"

  describe "an instance" do
    let(:obj) { klass.new({'track_id' => 'some_track_guid'}) }
    subject { obj }
    its(:media_type_sym) { should be(:track) }
  end

end
