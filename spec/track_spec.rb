require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Track do

  let(:klass)             { Helix::Track }
  subject                 { klass }
  its(:guid_name)         { should eq('track_id') }
  its(:resource_label_sym)    { should be(:track)   }
  its(:plural_resource_label) { should eq('tracks') }
  [:find, :create, :all, :find_all, :where].each do |crud_call|
    it { should respond_to(crud_call) }
  end

  describe "Constants"

  describe "an instance" do
    let(:obj)            { klass.new({'track_id' => 'some_track_guid'}) }
    subject              { obj }
    its(:resource_label_sym) { should be(:track) }
    [:destroy, :update].each do |crud_call|
      it { should respond_to(crud_call) }
    end
  end
end
