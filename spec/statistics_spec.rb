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

        subject     { mod.method(meth) }
        its(:arity) { should eq(-1)    }

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

  end

end
