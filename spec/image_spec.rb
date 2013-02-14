require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Image do
  let(:klass) { Helix::Image }

  subject { klass }
  its(:ancestors) { should include(Helix::Base) }
  its(:guid_name) { should eq('image_id') }
  its(:resource_label_sym)    { should be(:image)   }
  its(:plural_resource_label) { should eq('images') }
  [:find, :create, :all, :find_all, :where].each do |crud_call|
    it { should respond_to(crud_call) }
  end

  describe "Constants"

  describe "an instance" do
    let(:obj) { klass.new({'image_id' => 'some_image_guid'}) }
    subject { obj }
    its(:resource_label_sym) { should be(:image) }
    [:destroy, :update].each do |crud_call|
      it { should respond_to(crud_call) }
    end
  end

end
