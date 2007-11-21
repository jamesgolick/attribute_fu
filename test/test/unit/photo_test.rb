require File.dirname(__FILE__) + '/../test_helper'

class PhotoTest < ActiveSupport::TestCase
  should_have_many :comments
end
