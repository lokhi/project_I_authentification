require 'spec_helper'

def app
  Sinatra::Application
end

describe "accessing to the site without being connected" do
  it "should redirect the user to sauth/login" do
    get '/'
    follow_redirect!
    last_request.path.should == '/login'
  end
end

describe "registration" do
  it "should be possible to register an user" do
    get '/register'
    last_response.should be_ok
  end
  
  it "should get the data post by the user" do
    post '/register', "login"=>"toto","password"=>"1234"
    last_response.should be_ok
  end
    
    
end






