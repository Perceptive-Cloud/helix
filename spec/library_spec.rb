require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Library do

  let(:klass) { Helix::Library }
  subject     { klass }

  mods = [ Helix::Base, Helix::RESTful ]
  mods.each { |mod| its(:ancestors) { should include(mod) } }
  its(:ancestors) { should_not include(Helix::Media) }

  its(:guid_name)             { should eq('name')       }
  its(:resource_label_sym)    { should be(:library)     }
  its(:plural_resource_label) { should eq('libraries')  }
  [:find, :create, :all, :find_all, :where].each do |crud_call|
    it { should respond_to(crud_call) }
  end

  describe "Constants"

  describe "an instance" do
    let(:obj)            { klass.new({'library_id' => 'some_library_id'}) }
    subject              { obj }
    its(:resource_label_sym) { should be(:library) }
    [:destroy, :update].each do |crud_call|
      it { should respond_to(crud_call) }
    end
  end

end
