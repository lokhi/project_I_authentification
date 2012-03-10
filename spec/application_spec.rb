require_relative 'spec_helper'
require 'application'

describe Application do
after(:each) do
  u = Application.find_by_name("appli1")
  u.destroy if !u.nil?
end
describe "information missing" do
 it "should not be valid without any attribut" do
   subject.valid?.should == false
 end
 
 it "should not be valid without a name" do
   subject.adresse="adr"
   subject.secret="secret"
   subject.user_id=User.new
   subject.valid?.should == false
 end
 
 it "should not be valid without an adresse" do
   subject.name="appli1"
   subject.secret="secret"
   subject.user_id=User.new
   subject.valid?.should == false
 end
 
 it "should not be valid without an user_id" do
   subject.name="appli1"
   subject.adresse="adr"
   subject.secret="secret"
   subject.valid?.should == false
 end
 
end

describe "duplicate name" do
  it "should not be valid with a name who already exist" do
    a = Application.new({"name"=>"appli1","adresse"=>"adrs","secret"=>"secret","user_id"=>User.new})
    a.save
    b = Application.new({"name"=>"appli1","adresse"=>"adrs2","secret"=>"secret2","user_id"=>User.new})
    b.valid?.should == false
  end
end

describe "secret" do 
 it "should be generate" do
   a = Application.new({"name"=>"appli1","adresse"=>"adrs","user_id"=>User.new})
   a.save
   a.secret.nil?.should == false
 end
end
  
end
