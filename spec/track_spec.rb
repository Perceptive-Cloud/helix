require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Track do

  subject { described_class }
  mods = [ Helix::Base, Helix::Durationed, Helix::Media ]
  mods.each { |mod| its(:ancestors) { should include(mod) } }
  its(:guid_name)             { should eq('track_id') }
  its(:resource_label_sym)    { should be(:track)     }
  its(:plural_resource_label) { should eq('tracks')   }
  [:find, :create, :all, :find_all, :where].each do |crud_call|
    it { should respond_to(crud_call) }
  end

  describe "Constants"

  ### INSTANCE METHODS

  describe "an instance" do
    obj = described_class.new({'track_id' => 'some_track_guid'})
    subject { obj }
    its(:resource_label_sym) { should be(:track) }
    [:destroy, :update].each do |crud_call|
      it { should respond_to(crud_call) }
    end
    it_behaves_like "downloads", obj
    it_behaves_like "plays",     obj
  end

  ### CLASS METHODS

  it_behaves_like "upload_sig_opts", Helix::Track
  it_behaves_like "uploads",         Helix::Track

end
