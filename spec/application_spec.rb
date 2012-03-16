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

describe "encryption of a login with the application key" do
 before(:each) do
      @app = double(Application)
      Application.stub(:find_by_name){@app}
      @app.stub(:key){"-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDvqAuECzBu8JYrYleC245UZVyB
3N11guYosh0fHaAstywPWblHwq0es92nxEtp/qin051s+48/0lu1eKQnpfhRqOIm
xRhnyn9Vl7eR2Ssjg/yIhu+Q1nQgAnviWa6ktFbKgnxayy4Jd2a0XDsnxDWr21bQ
mEbgekzzcZIEijHeLQIDAQAB
-----END PUBLIC KEY-----"}
       @pubkey = double(OpenSSL::PKey::RSA)
       OpenSSL::PKey::RSA.stub(:new){@pubkey}
       @pubkey.stub(:public_encrypt){"totoc"}
       
    end
     
     it "should read the private key of the application" do
        Application.should_receive(:find_by_name).and_return(@app)
        @app.should_receive(:key)
        Application.appli_crypte_encode("appli","toto")
      end
      
    it "should create the key with the file" do
      OpenSSL::PKey::RSA.should_receive(:new)
      Application.appli_crypte_encode("appli","toto")
    end
    
    it "should encrypt the login" do
      @pubkey.should_receive(:public_encrypt).with("toto")
      Application.appli_crypte_encode("appli","toto")
    end
    
    it "should encode the encrypted login" do
      Base64.should_receive(:urlsafe_encode64)
      Application.appli_crypte_encode("appli","toto")
    end
end



  

