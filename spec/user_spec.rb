require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::User do

  let(:klass) { Helix::User }
  subject     { klass }

  mods = [ Helix::Base, Helix::RESTful ]
  mods.each { |mod| its(:ancestors) { should include(mod) } }
  its(:ancestors) { should_not include(Helix::Media) }

  its(:guid_name)             { should eq('user_id') }
  its(:resource_label_sym)    { should be(:user)     }
  its(:plural_resource_label) { should eq('users')   }
  [:find, :create, :all, :find_all, :where].each do |crud_call|
    it { should respond_to(crud_call) }
  end

  describe "Constants"

  describe "an instance" do
    let(:obj)            { klass.new({}) }
    subject              { obj }
    its(:resource_label_sym) { should be(:user) }
    [:destroy, :update].each do |crud_call|
      it { should respond_to(crud_call) }
    end
  end
end
