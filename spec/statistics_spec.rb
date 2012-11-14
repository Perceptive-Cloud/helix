require File.expand_path('../spec_helper', __FILE__)
require 'helix'

STATS_IMAGE_TYPES = %w(album image)
STATS_MEDIA_TYPES = STATS_IMAGE_TYPES + %w(audio video)
STATS_TYPES       = %w(delivery ingest storage)
MEDIA_NAME_OF     = {
  'album' => 'image',
  'audio' => 'track'
}

describe Helix::Statistics do
  let(:mod) { Helix::Statistics }

  describe "Constants"

  STATS_TYPES.each do |stats_type|
    STATS_MEDIA_TYPES.each do |media_type|

      next if STATS_IMAGE_TYPES.include?(media_type) and stats_type == 'ingest'

      describe ".#{media_type}_#{stats_type}_stats" do
        let(:meth)  { "#{media_type}_#{stats_type}_stats" }
        let(:mock_config) { mock(Helix::Config, build_url: :built_url, get_response: :response) }
        before(:each) do Helix::Config.stub(:instance) { mock_config } end

        subject     { mod.method(meth) }
        its(:arity) { should eq(-1)    }

        if stats_type == 'delivery'
          media_name = MEDIA_NAME_OF[media_type] || media_type
          context "when given opts containing a :#{media_name}_id" do
            let(:opts) { {group: :daily, "#{media_name}_id".to_sym => "the_#{media_name}_id".to_sym} }
            it "should refer to the Helix::Config instance" do
              Helix::Config.should_receive(:instance) { mock_config }
              mod.send(meth, opts)
            end
            it "should delete :#{media_name}_id from opts" do
              opts.should_receive(:delete).with("#{media_name}_id".to_sym) { "the_#{media_name}_id".to_sym }
              mod.send(meth, opts)
            end
            it "should call config.build_url(guid: the_#{media_name}_id, media_type: :#{media_name}s, action: :statistics)" do
              mock_config.should_receive(:build_url).with({guid: "the_#{media_name}_id".to_sym, media_type: "#{media_name}s".to_sym, action: :statistics}) { :built_url }
              mod.send(meth, opts)
            end
            it "should return config.get_response(built_url, opts.merge(sig_type: :view)" do
              mock_config.should_receive(:get_response).with(:built_url, {group: :daily, sig_type: :view}) { :response }
              expect(mod.send(meth, opts)).to eq(:response)
            end
          end
          context "when given opts NOT containing a :#{media_name}_id" do
            let(:opts) { {group: :daily} }
            it "should refer to the Helix::Config instance" do
              Helix::Config.should_receive(:instance) { mock_config }
              mod.send(meth, opts)
            end
            it "should (fail to) delete :#{media_name}_id from opts" do
              opts.should_receive(:delete).with("#{media_name}_id".to_sym) { nil }
              mod.send(meth, opts)
            end
            it "should call config.build_url(media_type: :statistics, action: :#{media_name}_delivery)" do
              mock_config.should_receive(:build_url).with({media_type: :statistics, action: "#{media_name}_delivery".to_sym}) { :built_url }
              mod.send(meth, opts)
            end
            it "should return config.get_response(built_url, opts.merge(sig_type: :view)" do
              mock_config.should_receive(:get_response).with(:built_url, {group: :daily, sig_type: :view}) { :response }
              expect(mod.send(meth, opts)).to eq(:response)
            end
          end
        end

      end
    end

    describe ".track_#{stats_type}_stats" do
      let(:meth)  { "track_#{stats_type}_stats" }

      subject     { mod.method(meth) }
      its(:arity) { should eq(-1)    }

      context "when given no arg" do
        it "should call audio_#{stats_type}_stats({})" do
          mod.should_receive("audio_#{stats_type}_stats").with({}) { :expected }
          expect(mod.send(meth)).to be(:expected)
        end
      end

      context "when given {}" do
        it "should call audio_#{stats_type}_stats({})" do
          mod.should_receive("audio_#{stats_type}_stats").with({}) { :expected }
          expect(mod.send(meth, {})).to be(:expected)
        end
      end

      context "when given :some_opts" do
        it "should call audio_#{stats_type}_stats(:some_opts)" do
          mod.should_receive("audio_#{stats_type}_stats").with(:some_opts) { :expected }
          expect(mod.send(meth, :some_opts)).to be(:expected)
        end
      end

    end

    next if stats_type == 'ingest'
    describe ".album_#{stats_type}_stats" do
      let(:meth)  { "album_#{stats_type}_stats" }

      subject     { mod.method(meth) }
      its(:arity) { should eq(-1)    }

      context "when given no arg" do
        it "should call image_#{stats_type}_stats({})" do
          mod.should_receive("image_#{stats_type}_stats").with({}) { :expected }
          expect(mod.send(meth)).to be(:expected)
        end
      end

      context "when given {}" do
        it "should call image_#{stats_type}_stats({})" do
          mod.should_receive("image_#{stats_type}_stats").with({}) { :expected }
          expect(mod.send(meth, {})).to be(:expected)
        end
      end

      context "when given :some_opts" do
        it "should call image_#{stats_type}_stats(:some_opts)" do
          mod.should_receive("image_#{stats_type}_stats").with(:some_opts) { :expected }
          expect(mod.send(meth, :some_opts)).to be(:expected)
        end
      end

    end

  end

end
