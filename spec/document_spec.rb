require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Document do

  subject { described_class }
  mods = [ Helix::Base, Helix::Media ]
  mods.each { |mod| its(:ancestors) { should include(mod) } }
  its(:guid_name)             { should eq('document_id') }
  its(:resource_label_sym)    { should be(:document)     }
  its(:plural_resource_label) { should eq('documents')   }
  [:find, :create, :all, :find_all, :where].each do |crud_call|
    it { should respond_to(crud_call) }
  end

  describe "Constants"

  ### INSTANCE METHODS

  describe "an instance" do
    obj = described_class.new({'document_id' => 'some_document_guid'})
    subject { obj }
    its(:resource_label_sym) { should be(:document) }
    [:destroy, :update].each do |crud_call|
      it { should respond_to(crud_call) }
    end
    it_behaves_like "downloads", obj
    it_behaves_like "plays",     obj
  end

  ### CLASS METHODS

  describe ".upload_sig_opts" do
    let(:meth)        { :upload_sig_opts }
    let(:mock_config) { double(Helix::Config, credentials: {}) }
    subject           { described_class.method(meth) }
    its(:arity)       { should eq(0) }
    it "should be private" do expect(described_class.private_methods).to include(meth) end
    context "when called" do
      subject { described_class.send(meth) }
      before(:each) do described_class.stub(:config) { mock_config } end
      it "should be a Hash" do expect(described_class.send(meth)).to be_a(Hash) end
      its(:keys) { should match_array([:contributor, :company_id, :library_id]) }
      context "the value for :contributor" do
        it "should be config.credentials[:contributor]" do
          mock_config.should_receive(:credentials) { {contributor: :expected_contributor} }
          expect(described_class.send(meth)[:contributor]).to be(:expected_contributor)
        end
      end
      context "the value for :company_id" do
        it "should be config.credentials[:company]" do
          mock_config.should_receive(:credentials) { {company: :expected_company} }
          expect(described_class.send(meth)[:company_id]).to be(:expected_company)
        end
      end
      context "the value for :library_id" do
        it "should be config.credentials[:library]" do
          mock_config.should_receive(:credentials) { {library: :expected_library} }
          expect(described_class.send(meth)[:library_id]).to be(:expected_library)
        end
      end
    end
  end

  it_behaves_like "upload_sig_opts", Helix::Document
  it_behaves_like "uploads",         Helix::Document

end
