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
  
  
  context "authentification for an application" do
    before(:each) do
      @app = double(Application)
      Application.stub(:find_by_name){@app}
      User.stub(:authenticate){true}
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
  
  
  
     it "should use the user authentication" do
      User.should_receive(:authenticate)
      User.appli_authenticate({"login"=>"toto","password"=>"foo"},"appli")
     end
     
     it "should read the private key of the application" do
        Application.should_receive(:find_by_name).and_return(@app)
        @app.should_receive(:key)
        User.appli_authenticate({"login"=>"toto","password"=>"foo"},"appli")
      end
      
    it "should create the key with the file" do
      OpenSSL::PKey::RSA.should_receive(:new)
      User.appli_authenticate({"login"=>"toto","password"=>"foo"},"appli")
    end
    
    it "should encrypt the login" do
      @pubkey.should_receive(:public_encrypt).with("toto")
      User.appli_authenticate({"login"=>"toto","password"=>"foo"},"appli")
    end
    
    it "should encode the encrypted login" do
      Base64.should_receive(:urlsafe_encode64)
      User.appli_authenticate({"login"=>"toto","password"=>"foo"},"appli")
    end
  end
end
