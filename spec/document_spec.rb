require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Document do
  let(:klass) { Helix::Document }

  subject { klass }
  its(:ancestors) { should include(Helix::Base) }
  its(:guid_name) { should eq('document_id') }
  its(:resource_label_sym)    { should be(:document)   }
  its(:plural_resource_label) { should eq('documents') }
  [:find, :create, :all, :find_all, :where].each do |crud_call|
    it { should respond_to(crud_call) }
  end

  describe "Constants"

  describe "an instance" do
    let(:obj) { klass.new({'document_id' => 'some_document_guid'}) }
    subject { obj }
    its(:resource_label_sym) { should be(:document) }
    [:destroy, :update].each do |crud_call|
      it { should respond_to(crud_call) }
    end
  end

end
