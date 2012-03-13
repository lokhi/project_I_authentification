require 'spec_helper'
require_relative '../appli1'
def app
  Sinatra::Application
end


describe "the home page" do
  it "should return the home page of the application" do
    get '/' 
    last_response.body.should include("Application")
  end
end

describe "protected area" do
  context "user not connected" do

    it "should redirect to sauth/appli1/session/new?origin=/protected" do
      get '/protected'
      follow_redirect!
      last_request.params['origin'].should == "/protected"
    end
    
    context "receiving the sauth response" do
      it "should decode the login in base64" do
         Base64.should_receive(:urlsafe_decode64).with("dG90bw==")
         get '/protected', {"login"=>"dG90bw==", "secret"=>"123"}
      end
      
      it "should read the private key" do
        File.should_receive(:read).with("private.pem")
        get '/protected', {"login"=>"dG90bw==", "secret" => "123"}
      end
      
      
   	
    end
    
  end
end
