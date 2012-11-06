require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Album do
  let(:klass) { Helix::Album }

  subject { klass }
  its(:ancestors) { should include(Helix::Base) }
  its(:guid_name) { should eq('album_id') }
  its(:plural_media_type) { should eq('albums') }

  describe "Constants"

  describe "an instance" do
    let(:obj) { klass.new({'album_id' => 'some_album_guid'}) }
    subject { obj }
    its(:media_type_sym) { should be(:album) }
  end

end
