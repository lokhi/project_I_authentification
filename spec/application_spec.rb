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
  end
  
   it "should include the password module" do
    Application.included_modules.should include(CrypteEncode)
  end
  
  it "should encrypte the login" do
    Application.should_receive(:appli_crypte_encode)
    Application.generate_link("appli","toto","/protected","secret")
  end
  
  it "should find the application in the db" do
    Application.should_receive(:find_by_name)
    Application.generate_link("appli","toto","/protected","secret")
  end

  it "should return the redirect adresse" do
    Application.generate_link("appli","toto","/protected","secret").should == "http://appli1.com/protected?login=totocrypted&secret=secret"
  end

end


  

