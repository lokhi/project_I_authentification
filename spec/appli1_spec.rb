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
    it "should generate a secret and stock it into a sessions" do
      get '/protected'
      last_request.env["rack.session"]["secret"].nil?.should == false
    end
    
    it "should redirect to sauth/appli1/session/new?origin=/protected&secret=???" do
      get '/protected'
      follow_redirect!
      last_request.params['origin'].should == "/protected"
      last_request.params['secret'].nil?.should be_false
    end
    
    it "should receive the login of the user from sauth" do
      get '/protected', {"secret"=>"12345"}
    
    end
   
  end
end
