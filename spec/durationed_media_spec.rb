require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::DurationedMedia do

  def import_xml(values={})
    { list: { entry: values[:url_params] || {} } }.to_xml(root: :add)
  end

  klasses = [ Helix::Video, Helix::Track ]
  klasses.each do |klass|
    subject         { klass }
    its(:ancestors) { should include(Helix::Base) }

    describe "Constants"

    let(:sig_opts)  { { contributor:  :helix,
                        library_id:   :development } }

    url_opts      =   { action:         :create_many,
                        resource_label: klass.send(:plural_resource_label),
                        content_type:   :xml }

    describe ".import" do
      let(:meth)        { :import }
      let(:mock_config) { mock(Helix::Config) }
      subject           { klass.method(meth) }
      its(:arity)       { should eq(-1) }
      let(:params)      { { params:       { signature: :some_sig },
                            content_type: "text/xml" } }
      before            { Helix::Config.stub(:instance) { mock_config } }

      it "should get an ingest signature" do
        mock_config.should_receive(:build_url).with(url_opts)
        mock_config.should_receive(:signature).with(:ingest, sig_opts) { :some_sig }
        RestClient.should_receive(:post).with(nil, import_xml, params)
        klass.send(meth)
      end
    end

    describe ".get_xml" do
      let(:meth)  { :get_xml }
      subject     { klass.method(meth) }
      its(:arity) { should eq(-1) }
      context "when :use_raw_xml is present in attrs" do
        let(:use_raw_xml) { { use_raw_xml: :xml } }
        it "should return the value of attrs[:use_raw_xml]" do
          expect(klass.send(meth, use_raw_xml)).to eq(:xml)
        end
      end
      context "when hash is passed without :use_raw_xml" do
        let(:attrs) { { url_params: { attribute: :value } } }
        it "should convert attrs into xml" do
          expect(klass.send(meth, attrs)).to eq(import_xml(attrs))
        end
      end
      context "when nothing in passed in" do
        it "should return valid xml" do
          expect(klass.send(meth)).to eq(import_xml)
        end
      end
    end

    describe ".url_opts_for" do
      let(:meth)  { :url_opts_for }
      subject     { klass.method(meth) }
      its(:arity) { should eq(-1) }
      it "should return a valid hash url options for Helix::Config#build_url" do
         expect(klass.send(meth)[:create_many]).to eq(url_opts)
      end
    end

    describe ".get_url_for" do
      let(:meth)  { :get_url_for }
      subject     { klass.method(meth) }
      its(:arity) { should eq(2) }
      it "should call Helix::Config#build_url with url opts" do
        Helix::Config.instance.should_receive(:build_url).with(klass.send(:url_opts_for)[:create_many])
        klass.send(meth, :create_many, {})
      end
    end

    describe ".get_params" do
      let(:meth)  { :get_params }
      subject     { klass.method(meth) }
      its(:arity) { should eq(-1) }
      it "should call Helix::Config#signature and return a hash of params" do
        Helix::Config.instance.should_receive(:signature).with(:ingest, sig_opts) { :sig }
        expect(klass.send(meth)).to eq({ params: { signature: :sig } })
      end
    end
  end
end
