require_relative 'spec_helper'
require 'user'

describe User do

  context "without login and password" do
    it "should not be valid" do
      subject.valid?.should == false
    end
  end
  
  it "should not be valid with just a login" do
    u = User.new
    u.login = "toto"
    u.valid?.should == false
  end
  
  it "should not be valid with just a password" do
    u = User.new
    u.password = "1234"
    u.valid?.should == false
  end
  
   context "duplicate login" do
    it "should not be valid with a login who already exists" do
    u = User.new
    u.login = "toto"
    u.password ="123"
    u.save
    
    k=User.new
    k.login ="toto"
    k.password="123"
    k.valid?.should == false
    end
  end

  
  context "Encryption of the password" do
    it "should include the password module" do
      User.included_modules.should include(Password)
    end
  end
end
