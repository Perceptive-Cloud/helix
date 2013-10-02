shared_examples_for "plays" do |obj|  
  describe "#play" do
    let(:meth)        { :play }
    let(:mock_config) { double(Helix::Config, build_url: :the_built_url, signature: :some_sig) }
    subject      { obj.method(meth) }
    let(:params) { { params: {signature: :some_sig } } }
    before do
      obj.stub(:config)            { mock_config }
      obj.stub(:guid)              { :some_guid  }
      obj.stub(:plural_resource_label) { :resource_label }
      RestClient.stub(:get) { '' }
    end
    { '' => '', mp3: :mp3, nil => '' }.each do |arg,actual|
      build_url_h = {action: :play, content_type: actual, guid: :some_guid, resource_label: :resource_label}
      context "when given {content_type: #{arg}" do
        it "should build_url(#{build_url_h})" do
          mock_config.should_receive(:build_url).with(build_url_h)
          obj.send(meth, content_type: arg)
        end
        it "should get a view signature" do
          mock_config.should_receive(:signature).with(:view) { :some_sig }
          obj.send(meth, content_type: arg)
        end
        it "should return an HTTP get to the built URL with the view sig" do
          mock_config.stub(:build_url).with(build_url_h) { :the_url }
          RestClient.should_receive(:get).with(:the_url, params) { :expected }
          expect(obj.send(meth, content_type: arg)).to be(:expected)
        end
      end
    end
  end
end
