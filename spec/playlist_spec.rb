require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Playlist do

  let(:klass) { described_class }
  subject     { klass }
  mods = [ Helix::Base, Helix::RESTful ]
  mods.each { |mod| its(:ancestors) { should include(mod) } }
  its(:guid_name)             { should eq('id') }
  its(:resource_label_sym)    { should be(:playlist)     }
  its(:plural_resource_label) { should eq('playlists')   }
  [:find, :create, :all, :find_all, :where].each do |crud_call|
    it { should respond_to(crud_call) }
  end

  describe "Constants"

  ### INSTANCE METHODS

  describe "an instance" do
    let(:obj) { klass.new({playlist_id: 'some_playlist_guid'}) }
    subject   { obj }
    its(:resource_label_sym) { should be(:playlist) }

    [:destroy, :update].each do |crud_call|
      it { should respond_to(crud_call) }
    end

  end

  ### CLASS METHODS

end
