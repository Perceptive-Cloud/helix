ENV["RAILS_ENV"] = "test"

require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
  add_group 'Libraries', 'lib'
end

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
      klass.should_receive(:upload_server_name) { :some_server_url }
      File.should_receive(:new).with(:some_file.to_s, "rb") { :some_file }
      RestClient.should_receive(:post).with(:some_server_url,
                                            file_hash,
                                            multipart_hash)
      klass.should_receive(:http_close)
      klass.send(meth, :some_file, opts)
    end
  end
end
