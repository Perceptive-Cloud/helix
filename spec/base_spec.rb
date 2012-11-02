require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Base do
  let(:klass) { Helix::Base }

  subject { klass }

  describe ".find" do
    subject { klass.method(:find) }
    its(:arity) { should eq(-2) }
    context "when given a guid" do
      subject { klass }
      let(:guid) { :a_guid }
      let(:meth) { :find }
      let(:mock_instance) { mock(Object, :load => nil) }
      it "should instantiate with attributes: { guid_name => the_guid }" do
        klass.should_receive(:guid_name) { :the_guid_name }
        klass.should_receive(:new).with({attributes: { the_guid_name: guid }}) { mock_instance }
        klass.send(meth, guid)
      end
      it "should load" do
        klass.stub(:guid_name) { :the_guid_name }
        klass.stub(:new) { mock_instance }
        mock_instance.should_receive(:load) { :expected }
        expect(klass.send(meth, guid)).to eq(:expected)
      end
    end
  end

  describe "Constants"

  # attr_accessor attributes

end
