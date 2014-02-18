require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix do
  let(:klass) { described_class }

  describe "Constants"

  describe "scope_to_company" do
    let(:meth) { :scope_to_company }
    let(:the_co_id) { :the_co_id }
    describe "arity" do
      subject { klass.method(meth) }
      its(:arity) { should eq(1) }
    end
    it "should add the company arg to credentials" do
      klass.send(meth, the_co_id)
      expect(Helix::Config.instance.credentials).to include(company: the_co_id)
    end
    it "should clear any pre-exisiting library from credentials" do
      klass.send(:scope_to_library, :the_lib_name)
      expect(Helix::Config.instance.credentials).to include(library: :the_lib_name)
      klass.send(meth, the_co_id)
      expect(Helix::Config.instance.credentials.keys).not_to include(:library)
    end
  end

  describe "scope_to_library" do
    let(:meth) { :scope_to_library }
    let(:the_lib_name) { :the_lib_name }
    describe "arity" do
      subject { klass.method(meth) }
      its(:arity) { should eq(1) }
    end
    it "should add the library arg to credentials" do
      klass.send(meth, the_lib_name)
      expect(Helix::Config.instance.credentials).to include(library: the_lib_name)
    end
  end

  describe "set_license_key" do
    let(:meth) { :set_license_key }
    let(:the_key) { :alicense_key }
    describe "arity" do
      subject { klass.method(meth) }
      its(:arity) { should eq(1) }
    end
    it "should add the license_key arg to credentials" do
      klass.send(meth, the_key)
      Helix::Config.instance.credentials.should include(license_key: the_key)
    end
  end

end
