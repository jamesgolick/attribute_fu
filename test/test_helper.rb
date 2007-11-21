$:.reject! { |e| e.include? 'TextMate' } # rails edge gems fix for textmate builder conflict => http://macromates.com/ticket/show?ticket_id=F4DA8B03
require 'test/unit'
require 'rubygems'
require 'activesupport'
require File.dirname(__FILE__)+'/../vendor/shoulda/context'

class Test::Unit::TestCase
  class << self
    include ThoughtBot::Shoulda::Context
  end
end
