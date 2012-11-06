require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Image do
  let(:klass) { Helix::Image }

  subject { klass }
  its(:ancestors) { should include(Helix::Base) }
  its(:guid_name) { should eq('image_id') }
  its(:plural_media_type) { should eq('images') }

  describe "Constants"

  describe "an instance" do
    let(:obj) { klass.new({'image_id' => 'some_image_guid'}) }
    subject { obj }
    its(:media_type_sym) { should be(:image) }
  end

end
