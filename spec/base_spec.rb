require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Base do

  let(:klass) { Helix::Base }

  subject { klass }

  describe "Constants" do
    describe "METHODS_DELEGATED_TO_CLASS" do
      subject { klass::METHODS_DELEGATED_TO_CLASS }
      it { should eq([:guid_name, :resource_label_sym, :plural_resource_label]) }
    end
  end

  ### CLASS METHODS

  describe ".config" do
    let(:meth)  { :config }
    subject     { klass.method(meth) }
    its(:arity) { should eq(0) }
    describe "when called" do
      subject     { klass.send(meth) }
      it { should eq(Helix::Config.instance) }
    end
  end

  shared_examples_for "a search all with opts" do
    subject           { klass.method(meth) }
    its(:arity)       { should eq(-1) }
    context "when there is NOT a config instance" do
      before(:each) do Helix::Config.stub(:instance) { nil } end
      it "should raise a NoConfigurationLoaded exception" do
        lambda { klass.send(meth) }.should raise_error(Helix::NoConfigurationLoaded)
      end
    end
    context "when there is a config instance" do
      let(:mock_config) do
        dss = (0..2).map { |x| :"attrs_#{x}" }
        double(Helix::Config, build_url: :built_url, get_aggregated_data_sets: dss)
      end
      before(:each) do Helix::Config.stub(:instance) { mock_config } end
      context "and NOT given an opts Hash" do
        let(:plural_resource_label) { :videos }
        before(:each) do klass.stub(:plural_resource_label) { plural_resource_label } end
        it "should get_aggregated_data_sets(the_url, plural_resource_label, {sig_type: :view}" do
          opts = {sig_type: :view}
          mock_config.should_receive(:get_aggregated_data_sets).with(:built_url, plural_resource_label, opts) { [:expected] }
          klass.send(meth, opts)
        end
        [ Helix::Video ].each do |child|
          it "should should instantiate #{child.to_s} from each data_set" do
            opts = {sig_type: :view}
            children = child.send(meth, opts)
            children.each_with_index do |c,idx|
              expect(c).to be_a(child)
              expect(c.attributes).to be(:"attrs_#{idx}")
            end
          end
        end
      end
    end
  end

  shared_examples_for "a search all without opts" do
    subject { klass.method(meth) }
    context "when there is a config instance" do
      let(:mock_config) do
        dss = (0..2).map { |x| :"attrs_#{x}" }
        double(Helix::Config, build_url: :built_url, get_aggregated_data_sets: dss)
      end
      before(:each) do Helix::Config.stub(:instance) { mock_config } end
      context "and NOT given an opts Hash" do
        let(:plural_resource_label) { :videos }
        before(:each) do klass.stub(:plural_resource_label) { plural_resource_label } end
        it "should get_aggregated_data_sets(the_url, plural_resource_label, {sig_type: :view}" do
          opts = {sig_type: :view}
          mock_config.should_receive(:get_aggregated_data_sets).with(:built_url, plural_resource_label, opts) { [:expected] }
          klass.send(meth)
        end
        [ Helix::Video ].each do |child|
          it "should should instantiate #{child.to_s} from each data_set" do
            opts = {sig_type: :view}
            children = child.send(meth)
            children.each_with_index do |c,idx|
              expect(c).to be_a(child)
              expect(c.attributes).to be(:"attrs_#{idx}")
            end
          end
        end
      end
    end
  end

  describe ".find_all" do
    let(:meth) { :find_all }
    it_behaves_like "a search all with opts"
    it_behaves_like "a search all without opts"
  end

  describe ".all" do
    let(:meth)  { :all }
    subject     { klass.method(meth) }
    its(:arity) { should eq(0) }
    it_behaves_like "a search all without opts"
  end

  describe ".where" do
    let(:meth) { :where }
    it_behaves_like "a search all with opts"
    it_behaves_like "a search all without opts"
  end

  describe ".massage_attrs" do
    let(:meth)  { :massage_attrs }
    subject     { klass.method(meth) }
    its(:arity) { should eq(1) }
    let(:attrs) { Hash.new }
    it "should call massage_custom_field_attrs and massage_time_attrs" do
      klass.should_receive(:massage_time_attrs) { attrs }
      klass.should_receive(:massage_custom_field_attrs) { attrs }
      klass.send(meth, attrs)
    end
  end

  describe ".massage_time_attrs" do
    let(:meth)      { :massage_time_attrs }
    subject         { klass.method(meth) }
    its(:arity)     { should eq(1) }
    let(:time)      { Time.new(2013) }
    let(:attrs)     { { key_one: time.to_s, key_two: { key_three: time, key_four: { key_five: time.to_s } } } }
    let(:expected)  { { key_one: time, key_two: { key_three: time, key_four: { key_five: time } } } }
    it "should turn stringified time values into time objects" do
      expect(klass.send(meth, attrs)).to eq(expected)
    end
  end

  describe ".massage_custom_field_attrs" do
    let(:meth)        { :massage_custom_field_attrs }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(1) }
    let(:custom_hash) { { "custom_fields" => {"boole"=>[nil, nil], "@type"=>"hash"} } }
    let(:expected)    { { "custom_fields" => [{"name"=>"boole", "value"=>""}, {"name"=>"boole", "value"=>""}] } }
    it "should turn custom_hash into expected" do
      expect(klass.send(meth, custom_hash)).to eq(expected)
    end
    it "should return the custom_hash in its form" do
      expect(klass.send(meth, expected)).to eq(expected)
    end
    let(:custom_hash_with_false)  { { "custom_fields" => {"boole"=>false, "@type"=>"hash"} } }
    let(:expected_with_false)     { { "custom_fields" => [{"name"=>"boole", "value"=>"false"}] } }
    it "should turn custom_hash into expected" do
      expect(klass.send(meth, custom_hash_with_false)).to eq(expected_with_false)
    end
  end

  shared_examples_for "builds URL for load" do
    it "should call #guid" do
      obj.should_receive(:guid) { 'some_guid' }
      obj.send(meth)
    end
    it "should build_url(content_type: :json, guid: the_guid, resource_label: 'videos')" do
      mock_config.should_receive(:build_url).with(content_type: :json, guid: 'some_guid', resource_label: 'videos')
      RestClient.stub(:put)
      obj.send(meth)
    end
  end

  klasses = [ Helix::Album, Helix::Image, Helix::Playlist, Helix::Track, Helix::Video ]
  klasses.each do |klass|

    describe "an instance of class #{klass.to_s}" do
      let(:obj) { klass.new({}) }

    ### INSTANCE METHODS

      describe ".config" do
        let(:meth)  { :config }
        subject     { obj.method(meth) }
        its(:arity) { should eq(0) }
        describe "when called" do
          subject     { obj.send(meth) }
          context "and @config is already set" do
            before(:each) do obj.instance_variable_set(:@config, :cached_val) end
            it { should be(:cached_val) }
          end
          context "and @config is NOT already set" do
            before(:each) do obj.instance_variable_set(:@config, nil) end
            it { should eq(Helix::Config.instance) }
          end
        end
      end

      describe "#custom_field" do
        let(:meth) { :custom_field }
        describe "arity" do
          subject { obj.method(meth) }
          its(:arity) { should eq(1) }
        end
        it "should be modified_attributes['custom_fields'][arg]" do
          obj.stub(:modified_attributes) { {'custom_fields' => {key1: :value1}} }
          expect(obj.send(meth, :key1)).to be(:value1)
          expect(obj.send(meth, :key2)).to be(nil)
        end
      end

      describe "#custom_fields" do
        let(:meth) { :custom_fields }
        describe "arity" do
          subject { obj.method(meth) }
          its(:arity) { should eq(0) }
        end
        it "should delegate to modified_attributes['custom_fields']" do
          cfs = {key1: :value1}
          obj.stub(:modified_attributes) { {'custom_fields' => cfs} }
          expect(obj.send(meth)).to be(cfs)
        end
      end

      describe "#guid" do
        let(:meth) { :guid }
        it "should return @attributes[guid_name]" do
          mock_attributes = double(Object)
          obj.instance_variable_set(:@attributes, mock_attributes)
          obj.should_receive(:guid_name) { :the_guid_name }
          mock_attributes.should_receive(:[]).with(:the_guid_name) { :expected }
          expect(obj.send(meth)).to eq(:expected)
        end
      end

      describe "#guid_name" do
        let(:meth) { :guid_name }
        it "should delegate to the class" do
          klass.should_receive(meth) { :expected }
          expect(obj.send(meth)).to be(:expected)
        end
      end

      describe "#load" do
        let(:meth)  { :load }
        let(:mock_config) { double(Helix::Config) }
        subject     { obj.method(meth) }
        its(:arity) { should eq(-1) }
        before(:each) do
          obj.stub(:config)               { mock_config     }
          obj.stub(:guid)                 { 'some_guid'     }
          obj.stub(:signature)            { 'some_sig'      }
          obj.stub(:massage_raw_attrs)    { :massaged_attrs }
          mock_config.stub(:build_url)    { :expected_url   }
          mock_config.stub(:get_response) { :raw_attrs      }
          klass.stub(:resource_label_sym) { :video          }
        end
        context "when given no argument" do
          it_behaves_like "builds URL for load"
          it "should call klass.get_response(output_of_build_url, {sig_type: :view}) and return instance of klass" do
            mock_config.should_receive(:get_response).with(:expected_url, {sig_type: :view})
            expect(obj.send(meth)).to be_an_instance_of(klass)
          end
          it "should massage the raw_attrs" do
            obj.should_receive(:massage_raw_attrs).with(:raw_attrs)
            obj.send(meth)
          end
        end
        context "when given an opts argument of {key1: :value1}" do
          let(:opts)  { {key1: :value1} }
          it_behaves_like "builds URL for load"
          it "should call klass.get_response(output_of_build_url, opts.merge(sig_type: :view)) and return instance of klass" do
            mock_config.should_receive(:get_response).with(:expected_url, opts.merge(sig_type: :view))
            expect(obj.send(meth, opts)).to be_an_instance_of(klass)
          end
          it "should massage the raw_attrs" do
            obj.should_receive(:massage_raw_attrs).with(:raw_attrs)
            obj.send(meth, opts)
          end
        end
      end

      describe "#massage_raw_attrs" do
        let(:meth)      { :massage_raw_attrs }
        let(:guid_name) { :the_guid_name }

        subject     { obj.method(meth) }
        its(:arity) { should eq(1) }

        before(:each) { obj.stub(:guid_name) { guid_name } }
        context "when given {}" do
          let(:raw_attrs) { {} }
          subject { obj.send(meth, raw_attrs) }
          it { should eq(nil) }
        end
        context "when given {'site' => :site_contents}" do
          let(:raw_attrs) { {'site' => :site_contents} }
          subject { obj.send(meth, raw_attrs) }
          it { should eq(:site_contents) }
        end
        context "when given { guid_name => :the_val }" do
          let(:raw_attrs) { { guid_name => :the_val } }
          subject { obj.send(meth, raw_attrs) }
          it { should eq(raw_attrs) }
        end
        context "when given [{ guid_name => :the_val }]" do
          let(:raw_attrs) { [{ guid_name => :the_val }] }
          subject { obj.send(meth, raw_attrs) }
          it { should eq(raw_attrs.first) }
        end
      end

      describe "#method_missing" do
        let(:meth)  { :method_missing }
        subject     { obj.method(meth) }
        its(:arity) { should eq(1) }
        context "when given method_sym" do
          let(:method_sym) { :method_sym }
          let(:mock_attributes) { double(Object) }
          before(:each) do obj.instance_variable_set(:@attributes, mock_attributes) end
          context "and @attributes[method_sym.to_s] raises an exception" do
            before(:each) do mock_attributes.should_receive(:[]).with(method_sym.to_s).and_raise("some exception") end
            it "should raise a NoMethodError" do
              msg = "#{method_sym} is not recognized within #{klass}'s methods or @attributes"
              expect(lambda { obj.send(meth, method_sym) }).to raise_error(msg)
            end
          end
          context "and @attributes[method_sym.to_s] does NOT raise an exception" do
            before(:each) do mock_attributes.should_receive(:[]).with(method_sym.to_s) { :expected } end
            it "should return @attributes[method_sym.to_s]" do
              expect(obj.send(meth, method_sym)).to eq(:expected)
            end
          end
        end
      end

      describe "modified_attributes" do
        let(:meth) { :modified_attributes }

        describe "arity" do
          subject { obj.method(meth) }
          its(:arity) { should eq(0) }
        end

        describe "access" do
          subject { obj }
          its(:private_methods) { should include(meth) }
        end

        subject { obj.send(meth) }
        context "when @attributes is nil" do
          before(:each) do obj.instance_variable_set(:@attributes, nil) end
          it { should be(nil) }
        end
        context "when @attributes is {}" do
          before(:each) do obj.instance_variable_set(:@attributes, {}) end
          it { should eq({}) }
        end
        bases = [ {}, {'k1' => 'v1', 'k2' => 'v2'} ]
        potential_additions = [
          {'custom_fields' => nil},
          {'custom_fields' => [{}]},
          {'custom_fields' => [{'name' => nil}]},
          {'custom_fields' => [{'name' => nil}, {'name' => nil}]}
        ]
        bases.each do |base|
          potential_additions.each do |additions|
            attrs = base.merge(additions)
            context "when @attributes is #{attrs}" do
              before(:each) do obj.instance_variable_set(:@attributes, attrs) end
              it { should eq(attrs) }
            end
          end
          context "when @attributes is #{base.merge({'custom_fields' => [{'name' => 'some name'}]})}" do
            before(:each) do
              attrs = base.merge({'custom_fields' => [{'name' => 'some name'}]})
              obj.instance_variable_set(:@attributes, attrs)
            end
            it { should eq(base.merge("custom_fields" => {"some name"=>nil})) }
          end
          context "when @attributes is #{base.merge({'custom_fields' => [{'name' => 'some name'}, {'name' => 'other name'}]})}" do
            before(:each) do
              attrs = base.merge({'custom_fields' => [{'name' => 'some name'}, {'name' => 'other name'}]})
              obj.instance_variable_set(:@attributes, attrs)
            end
            it { should eq(base.merge("custom_fields" => {"some name"=>nil, "other name"=>nil})) }
          end
          context "when @attributes is #{base.merge({'custom_fields' => [{'name' => 'some name'}, {'name' => 'other name'}]})}" do
            before(:each) do
              attrs = base.merge({'custom_fields' => [{'name' => 'some name'}, {'name' => 'other name'}]})
              obj.instance_variable_set(:@attributes, attrs)
            end
            it { should eq(base.merge("custom_fields" => {"some name"=>nil, "other name"=>nil})) }
          end
          context "when @attributes is #{base.merge({'custom_fields' => [{'name' => 'some name', 'value' => nil}]})}" do
            before(:each) do
              attrs = base.merge({'custom_fields' => [{'name' => 'some name', 'value' => nil}]})
              obj.instance_variable_set(:@attributes, attrs)
            end
            it { should eq(base.merge("custom_fields" => {"some name"=>nil})) }
          end
          context "when @attributes is #{base.merge({'custom_fields' => [{'name' => 'some name', 'value' => nil}, {'name' => 'other name', 'value' => nil}]})}" do
            before(:each) do
              attrs = base.merge({'custom_fields' => [{'name' => 'some name', 'value' => nil}, {'name' => 'other name', 'value' => nil}]})
              obj.instance_variable_set(:@attributes, attrs)
            end
            it { should eq(base.merge("custom_fields" => {"some name"=>nil, "other name"=>nil})) }
          end
          context "when @attributes is #{base.merge({'custom_fields' => [{'name' => 'some name', 'value' => 'some value'}]})}" do
            before(:each) do
              attrs = base.merge({'custom_fields' => [{'name' => 'some name', 'value' => 'some value'}]})
              obj.instance_variable_set(:@attributes, attrs)
            end
            it { should eq(base.merge("custom_fields" => {"some name"=>"some value"})) }
          end
          context "when @attributes is #{base.merge({'custom_fields' => [{'name' => 'some name', 'value' => 'some value'}, {'name' => 'other name', 'value' => 'other value'}]})}" do
            before(:each) do
              attrs = base.merge({'custom_fields' => [{'name' => 'some name', 'value' => 'some value'}, {'name' => 'other name', 'value' => 'other value'}]})
              obj.instance_variable_set(:@attributes, attrs)
            end
            it { should eq(base.merge("custom_fields" => {"some name"=>"some value", "other name"=>"other value"})) }
          end
        end
      end

      describe "#raw_response" do
        let(:meth)  { :raw_response }
        subject     { obj.method(meth) }
        its(:arity) { should eq(0) }
        it "should return the response from config" do
          obj.config.stub!(:response).and_return :some_response
          expect(obj.send(meth)).to eq(obj.config.response)
        end
      end

    end

  end

end
