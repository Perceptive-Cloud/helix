require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Tag do

  let(:klass)             { Helix::Tag }
  subject                 { klass }
  its(:media_type_sym)    { should be(:tag)   }
  its(:plural_media_type) { should eq('tags') }
  
end