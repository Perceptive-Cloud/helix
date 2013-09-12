require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Paginates do

  class DummyClass;end

  before(:each) do
    @klass = DummyClass.new
    @klass.extend(Helix::Paginates)
  end


  describe "#get_aggregated_data_sets" do
    let(:meth)  { :get_aggregated_data_sets }
    subject     { @klass.method(meth) }
    its(:arity) { should eq(-3) }
    context "when called" do
      let(:opts)  { {opts_key1: :opts_val1, per_page: 99} }
      let(:label) { :videos }
      before(:each) do
        @klass.stub(:signature) { :the_sig }
      end
      subject { @klass.send(meth, :a_url, label, opts) }
      it "should successively call RestClient.get with the opts arg merged with pagination info and return the parsed results" do
        base_opts = {opts_key1: :opts_val1, per_page: 99, signature: :the_sig}
        opts1 = {params: base_opts.merge(page: 1)}
        opts2 = {params: base_opts.merge(page: 2)}
        opts3 = {params: base_opts.merge(page: 3)}
        non_final_response = double(String, headers: {is_last_page: 'false'})
        final_response     = double(String, headers: {is_last_page: 'true'})
        RestClient.should_receive(:get).with(:a_url, opts1) { non_final_response }
        RestClient.should_receive(:get).with(:a_url, opts2) { non_final_response }
        RestClient.should_receive(:get).with(:a_url, opts3) { final_response }
        @klass.stub(:parse_response_by_url_format).with(non_final_response, :a_url) { {label => [:non_final]} }
        @klass.stub(:parse_response_by_url_format).with(final_response, :a_url)     { {label => [:final]}     }
        expect(@klass.send(meth, :a_url, label, opts)).to eq([:non_final, :non_final, :final])
      end
    end
  end
end