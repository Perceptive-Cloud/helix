require File.expand_path('../spec_helper', __FILE__)
require 'helix'

STATS_MEDIA_TYPES = %w(audio image video)
STATS_TYPES       = %w(delivery ingest storage)

describe Helix::Statistics do
  let(:mod) { Helix::Statistics }

  describe "Constants"

  STATS_TYPES.each do |stats_type|
    STATS_MEDIA_TYPES.each do |media_type|

      next if media_type == 'image' and stats_type == 'ingest'

      describe ".#{media_type}_#{stats_type}_stats" do
        let(:meth)  { "#{media_type}_#{stats_type}_stats" }
        let(:mock_config) { mock(Helix::Config, build_url: :built_url, get_response: :response) }
        before(:each) do Helix::Config.stub(:instance) { mock_config } end

        subject     { mod.method(meth) }
        its(:arity) { should eq(-1)    }

        if media_type == 'audio' and stats_type == 'delivery'
          context "when given opts containing a :track_id" do
            let(:opts) { {group: :daily, track_id: :the_track_id} }
            it "should refer to the Helix::Config instance" do
              Helix::Config.should_receive(:instance) { mock_config }
              mod.send(meth, opts)
            end
            it "should delete :track_id from opts" do
              opts.should_receive(:delete).with(:track_id) { :the_track_id }
              mod.send(meth, opts)
            end
            it "should call config.build_url(guid: the_track_id, media_type: :tracks, action: :statistics)" do
              mock_config.should_receive(:build_url).with({guid: :the_track_id, media_type: :tracks, action: :statistics}) { :built_url }
              mod.send(meth, opts)
            end
            it "should return config.get_response(built_url, opts.merge(sig_type: :view)" do
              mock_config.should_receive(:get_response).with(:built_url, {group: :daily, sig_type: :view}) { :response }
              expect(mod.send(meth, opts)).to eq(:response)
            end
          end
          context "when given opts NOT containing a :track_id" do
            let(:opts) { {group: :daily} }
            it "should refer to the Helix::Config instance" do
              Helix::Config.should_receive(:instance) { mock_config }
              mod.send(meth, opts)
            end
            it "should (fail to) delete :track_id from opts" do
              opts.should_receive(:delete).with(:track_id) { nil }
              mod.send(meth, opts)
            end
            it "should call config.build_url(media_type: :statistics, action: :track_delivery)" do
              mock_config.should_receive(:build_url).with({media_type: :statistics, action: :track_delivery}) { :built_url }
              mod.send(meth, opts)
            end
            it "should return config.get_response(built_url, opts.merge(sig_type: :view)" do
              mock_config.should_receive(:get_response).with(:built_url, {group: :daily, sig_type: :view}) { :response }
              expect(mod.send(meth, opts)).to eq(:response)
            end
          end
        end
        if %(album image).include?(media_type) and stats_type == 'delivery'
          context "when given opts containing a :image_id" do
            let(:opts) { {group: :daily, image_id: :the_image_id} }
            it "should refer to the Helix::Config instance" do
              Helix::Config.should_receive(:instance) { mock_config }
              mod.send(meth, opts)
            end
            it "should delete :image_id from opts" do
              opts.should_receive(:delete).with(:image_id) { :the_image_id }
              mod.send(meth, opts)
            end
            it "should call config.build_url(guid: the_image_id, media_type: :images, action: :statistics)" do
              mock_config.should_receive(:build_url).with({guid: :the_image_id, media_type: :images, action: :statistics}) { :built_url }
              mod.send(meth, opts)
            end
            it "should return config.get_response(built_url, opts.merge(sig_type: :view)" do
              mock_config.should_receive(:get_response).with(:built_url, {group: :daily, sig_type: :view}) { :response }
              expect(mod.send(meth, opts)).to eq(:response)
            end
          end
          context "when given opts NOT containing a :image_id" do
            let(:opts) { {group: :daily} }
            it "should refer to the Helix::Config instance" do
              Helix::Config.should_receive(:instance) { mock_config }
              mod.send(meth, opts)
            end
            it "should (fail to) delete :image_id from opts" do
              opts.should_receive(:delete).with(:image_id) { nil }
              mod.send(meth, opts)
            end
            it "should call config.build_url(media_type: :statistics, action: :image_delivery)" do
              mock_config.should_receive(:build_url).with({media_type: :statistics, action: :image_delivery}) { :built_url }
              mod.send(meth, opts)
            end
            it "should return config.get_response(built_url, opts.merge(sig_type: :view)" do
              mock_config.should_receive(:get_response).with(:built_url, {group: :daily, sig_type: :view}) { :response }
              expect(mod.send(meth, opts)).to eq(:response)
            end
          end
        end
        if media_type == 'video' and stats_type == 'delivery'
          context "when given opts containing a :video_id" do
            let(:opts) { {group: :daily, video_id: :the_video_id} }
            it "should refer to the Helix::Config instance" do
              Helix::Config.should_receive(:instance) { mock_config }
              mod.send(meth, opts)
            end
            it "should delete :video_id from opts" do
              opts.should_receive(:delete).with(:video_id) { :the_video_id }
              mod.send(meth, opts)
            end
            it "should call config.build_url(guid: the_video_id, media_type: :videos, action: :statistics)" do
              mock_config.should_receive(:build_url).with({guid: :the_video_id, media_type: :videos, action: :statistics}) { :built_url }
              mod.send(meth, opts)
            end
            it "should return config.get_response(built_url, opts.merge(sig_type: :view)" do
              mock_config.should_receive(:get_response).with(:built_url, {group: :daily, sig_type: :view}) { :response }
              expect(mod.send(meth, opts)).to eq(:response)
            end
          end
          context "when given opts NOT containing a :video_id" do
            let(:opts) { {group: :daily} }
            it "should refer to the Helix::Config instance" do
              Helix::Config.should_receive(:instance) { mock_config }
              mod.send(meth, opts)
            end
            it "should (fail to) delete :video_id from opts" do
              opts.should_receive(:delete).with(:video_id) { nil }
              mod.send(meth, opts)
            end
            it "should call config.build_url(media_type: :statistics, action: :video_delivery)" do
              mock_config.should_receive(:build_url).with({media_type: :statistics, action: :video_delivery}) { :built_url }
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
