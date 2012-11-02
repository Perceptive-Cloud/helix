require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Base do
  let(:klass) { Helix::Base }

  subject { klass }

  describe ".find" do
    let(:meth) { :find }
    subject { klass.method(meth) }
    its(:arity) { should eq(-2) }
    context "when given a guid" do
      subject { klass }
      let(:guid) { :a_guid }
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

  describe "an instance" do
    let(:obj) { klass.new({}) }

    describe "#guid" do
      let(:meth) { :guid }
      it "should return @attributes[guid_name]" do
        mock_attributes = mock(Object)
        obj.instance_variable_set(:@attributes, mock_attributes)
        obj.should_receive(:guid_name) { :the_guid_name }
        mock_attributes.should_receive(:[]).with(:the_guid_name) { :expected }
        expect(obj.send(meth)).to eq(:expected)
      end
    end

    describe "#method_missing" do
      let(:meth) { :method_missing }
      subject { obj.method(meth) }
      its(:arity) { should eq(1) }
      context "when given method_sym" do
        let(:method_sym) { :method_sym }
        it "should return @attributes[method_sym.to_s]" do
          mock_attributes = mock(Object)
          obj.instance_variable_set(:@attributes, mock_attributes)
          mock_attributes.should_receive(:[]).with(method_sym.to_s) { :expected }
          expect(obj.send(meth, method_sym)).to eq(:expected)
        end
      end
    end

  end

end
