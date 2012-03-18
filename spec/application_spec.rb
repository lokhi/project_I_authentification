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
   subject.key="123"
   subject.user_id=User.new
   subject.valid?.should == false
 end
 
 it "should not be valid without an adresse" do
   subject.name="appli1"
   subject.key="123"
   subject.user_id=User.new
   subject.valid?.should == false
 end
 
  it "should not be valid without a key" do
   subject.name="appli1"
   subject.adresse="adr"
   subject.user_id=User.new
   subject.valid?.should == false
 end
 
 it "should not be valid without an user_id" do
   subject.name="appli1"
   subject.adresse="adr"
   subject.key="123"
   subject.valid?.should == false
 end
 
end



describe "duplicate name" do
  it "should not be valid with a name who already exist" do
    a = Application.new({"name"=>"appli1","adresse"=>"adrs","key"=>"1234","user_id"=>User.new})
    a.save
    b = Application.new({"name"=>"appli1","adresse"=>"adrs2","key"=>"1234","user_id"=>User.new})
    b.valid?.should == false
  end
end
end


describe "redirect link generation" do

  before (:each) do
    @app=double(Application)
    Application.stub(:appli_crypte_encode){"totocrypted"}
    Application.stub(:find_by_name){@app}
    @app.stub(:adresse){"http://appli1.com"}
    @app.stub(:key){"123"}
    @app.stub(:cypher){"totocrypted"}
  end
  
   it "should include the password module" do
    Application.included_modules.should include(CrypteEncode)
  end
  
  
  it "should find the application in the db" do
    Application.should_receive(:find_by_name)
    Application.generate_link("appli","toto","/protected","secret")
  end

  it "should return the redirect adresse" do
    Application.generate_link("appli","toto","/protected","secret").should == "http://appli1.com/protected?login=totocrypted&secret=secret"
  end

end


describe "listing of all application use by someone" do
  before(:each) do
    @use=double(Use)
    Use.stub(:where){@use}
    @use.stub(:each){@use}
    @use.stub(:application_id){1}
  end

  it "should use the where methode of Use" do
    Use.should_receive(:where)
    Application.list_app_used_by(1)
  end
  
  it "should list the result of where" do
    @use.should_receive(:each)
    Application.list_app_used_by(1)
  end
  
  #it "should search the application with an id" do
    #Application.should_receive(:find_by_id)
    #Application.list_app_used_by(1)
  #end
  
  it "should return a tab" do
    Application.list_app_used_by(1).should be_an Array
  end
end
