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

  describe ".process_opts" do
    context "opts is {content_type: :json}" do
      it { klass.process_opts({content_type: :json}).should eq({ content_type: :json }) }
    end
    context "opts is {content_type: :xml}" do
      it { klass.process_opts({content_type: :xml}).should eq({ content_type: :xml }) }
    end
    context "when opts is {k: :v}" do
      it { klass.process_opts({k: :v}).should eq({ k: :v, content_type: :xml }) }
    end
  end

  describe "an instance" do
    let(:obj)            { klass.new({'library_id' => 'some_library_id'}) }
    subject              { obj }
    its(:resource_label_sym) { should be(:library) }
    [:destroy, :update].each do |crud_call|
      it { should respond_to(crud_call) }
    end

  end

end
