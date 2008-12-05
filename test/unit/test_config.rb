require File.join(File.dirname(__FILE__), '../test_helper')

class UserTest < Test::Unit::TestCase

  context "Rackdapter::Config" do
  
    it "should load the config file" do
      config = Rackdapter::Config.new(File.join(File.dirname(__FILE__), '../rackdapter.yml'))
      config.apps.keys.include?(:test).should == true
    end
  
  end
  
end