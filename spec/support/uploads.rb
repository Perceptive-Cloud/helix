shared_examples_for "uploads" do |klass|
  describe ".upload" do
    let(:meth)            { :upload }
    let(:mock_config)     { double(Helix::Config) }
    subject               { klass.method(meth) }
    its(:arity)           { should eq(-2) }
    let(:file_hash)       { { file: :some_file } }
    let(:multipart_hash)  { { multipart: true  } }
    let(:opts)            { { k1: :v1, k2: :v2 } }
    it "should call upload_server_name and RestClient.post with params" do
      klass.should_receive(:upload_server_name) { :some_server_url }
      File.should_receive(:new).with(:some_file.to_s, "rb") { :some_file }
      RestClient.should_receive(:post).with(:some_server_url,
                                            file_hash,
                                            multipart_hash)
      klass.should_receive(:http_close)
      klass.send(meth, :some_file)
    end
    it "should accept an optional opts Hash" do
      klass.should_receive(:upload_server_name).with(opts) { :some_server_url }
      File.should_receive(:new).with(:some_file.to_s, "rb") { :some_file }
      RestClient.should_receive(:post).with(:some_server_url,
                                            file_hash,
                                            multipart_hash)
      klass.should_receive(:http_close)
      klass.send(meth, :some_file, opts)
    end
  end
  describe ".upload_server_name" do
    let(:meth)        { :upload_server_name }
    let(:mock_config) { double(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(-1) }
    let(:ingest_opts) { { default_k: :default_v } }
    let(:url_opts)    { { resource_label: "upload_sessions",
                          guid:           :some_sig,
                          action:         :http_open,
                          content_type:   ""  } }
    before            { Helix::Config.stub(:instance) { mock_config } }
    it "should call RestClient.get with correct url building" do
      klass.should_receive(:upload_sig_opts) { ingest_opts }
      mock_config.should_receive(:build_url).with(url_opts)             { :url }
      mock_config.should_receive(:signature).with(:upload, ingest_opts) { :some_sig }
      RestClient.should_receive(:get).with(:url)
      klass.send(meth)
    end
    it "should append a single-pair http_open_opts to upload_get's URL arg" do
      opts = {k: :v}
      klass.stub(:upload_sig_opts) { ingest_opts }
      mock_config.stub(:build_url).with(url_opts)             { :url }
      mock_config.stub(:signature).with(:upload, ingest_opts) { :some_sig }
      RestClient.should_receive(:get).with("url?k=v")
      klass.send(meth, opts)
    end
    it "should append a fuller http_open_opts to upload_get's URL arg" do
      opts = {k1: :v1, k2: :v2}
      klass.stub(:upload_sig_opts) { ingest_opts }
      mock_config.stub(:build_url).with(url_opts)             { :url }
      mock_config.stub(:signature).with(:upload, ingest_opts) { :some_sig }
      RestClient.should_receive(:get).with("url?k1=v1&k2=v2")
      klass.send(meth, opts)
    end
  end
  describe ".http_close" do
    let(:meth)        { :http_close }
    let(:mock_config) { double(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(0) }
    let(:url_opts)    { { resource_label: "upload_sessions",
                          guid:           :some_sig,
                          action:         :http_close,
                          content_type:   ""  } }
    before            { Helix::Config.stub(:instance) { mock_config } }
    it "should call RestClient.get with correct url building" do
      mock_config.should_receive(:build_url).with(url_opts) { :url }
      mock_config.should_receive(:signature).with(:upload, {}) { :some_sig }
      RestClient.should_receive(:get).with(:url)
      klass.send(meth)
    end
  end

  describe ".upload_get" do
    let(:meth)        { :upload_get }
    let(:mock_config) { double(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(-2) }
    let(:url_opts)    { { resource_label: "upload_sessions",
                          guid:           :some_sig,
                          action:         :upload_get,
                          content_type:   ""  } }
    before            { Helix::Config.stub(:instance) { mock_config } }
    it "should call RestClient.get with correct url building" do
      mock_config.should_receive(:build_url).with(url_opts) { :url }
      mock_config.should_receive(:signature).with(:upload, {}) { :some_sig }
      RestClient.should_receive(:get).with(:url)
      klass.send(meth, :upload_get)
    end
  end

  describe ".http_open" do
    let(:meth)        { :http_open }
    let(:mock_config) { double(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(-1) }
    it "should call upload_server_name" do
      klass.should_receive(:upload_server_name)
      klass.send(meth)
    end
    it "should pass its opts on to upload_server_name" do
      klass.should_receive(:upload_server_name).with(:opts)
      klass.send(meth, :opts)
    end
  end

  describe ".upload_open" do
    let(:meth)        { :upload_open }
    let(:mock_config) { double(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(-1) }
    it "should call upload_server_name" do
      klass.should_receive(:upload_server_name)
      klass.send(meth)
    end
    it "should pass its opts on to upload_server_name" do
      klass.should_receive(:upload_server_name).with(:opts)
      klass.send(meth, :opts)
    end
  end

  describe ".upload_close" do
    let(:meth)        { :upload_close }
    let(:mock_config) { double(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(0) }
    it "should call upload_server_name" do
      klass.should_receive(:http_close)
      klass.send(meth)
    end
  end
end
