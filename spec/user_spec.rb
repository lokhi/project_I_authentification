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
  after(:each) do
     u = User.find_by_login("totopourrspec")
     u.destroy
   end
    it "should not be valid with a login who already exists" do
    u = User.new
    u.login = "totopourrspec"
    u.password ="123"
    u.save
    k=User.new
    k.login ="totopourrspec"
    k.password="123"
    k.valid?.should == false
    end
  end

  
  context "Encryption of the password" do
  after(:each) do
     u = User.find_by_login("testpourrspec")
     u.destroy
   end
    it "should save the encrypt password in the database" do
      u = User.new
      u.login="testpourrspec"
      u.password="foo"
      u.save
      k=User.find_by_login("testpourrspec")
      k.password.should == '0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33'
    end
  end
end
