require_relative 'spec_helper'
require 'user'

describe User do

after(:each) do
     u = User.find_by_login("toto")
     u.destroy if !u.nil?
   end
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
  
  it "should not be valid with an empty password" do
    u = User.new
    u.login="toto"
    u.password = ""
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
    it "should save the encrypt password in the database" do
      u = User.new
      u.login="toto"
      u.password="foo"
      u.save
      k=User.find_by_login("toto")
      k.password.should == '0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33'
    end
  end
  
  
  context "authentification" do
    it "should authenticate an user" do
      u = User.new
      u.login="toto"
      u.password="foo"
      u.save
      User.authenticate({"login"=>"toto","password"=>"foo"}).should == u
    end
  end
end


describe "add utilisation of an application" do
  before(:each) do
    @us=double(Use)
    Use.stub(:new){@us}
    @us.stub(:user_id=)
    @us.stub(:application_id=)
    @us.stub(:save)
    @a=double(Application)
    @a.stub(:id)
    @u = User.new
    @u.login="toto"
    @u.password="foo"
    @u.save
  end
  it "should create an use" do
    Use.should_receive(:new)
    @u.use("appli")
  end
  
  it "should fill the user id of Use" do
    @us.should_receive(:user_id=)
    @u.use(@a.id)
  end
  
  it "should fill the application of Use" do
    @us.should_receive(:application_id=)
    @u.use(@a.id)
  end
  
  it "should save the use" do
    @us.should_receive(:save)
    @u.use(@a.id)
  end

end
