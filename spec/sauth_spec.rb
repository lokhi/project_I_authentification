require 'spec_helper'

def app
  Sinatra::Application
end

describe "accessing to the site without being connected" do
  it "should redirect the user to /login" do
    get '/'
    follow_redirect!
    last_request.path.should == '/login'
  end
end

describe "registration" do
  before(:each) do
   @params={"user" => {"login"=>"testrspec", "password"=>"1234"}}
   @user = double("user")
   User.stub(:new){@user}
  end

  it "should be possible to register an user" do
    get '/user/new'
    last_response.should be_ok
    last_response.body.should include("<title>Registration page</title>")
  end
  
  context "all params are valid" do
    it "should create an user" do
      User.should_receive(:new).with(@params["user"]).and_return(@user)
      post '/user', @params
    end
    
    it "should redirect to the login page" do
      @user.stub(:save){true}
      post '/user', @params
      follow_redirect!
      last_request.path.should == '/login'
    end
  end
  
  context "with invalid parameters" do
    it "should print the register page" do
      @user.stub(:save){false}
      post '/user', @params
      last_response.should be_ok
      last_response.body.should include("<title>Registration page</title>")
    end
  end
end

describe "authentification with the login form" do

  it "should use the user authentification" do
    params={"user" => {"login"=>"toto", "password" => "1234"}}
    User.stub(:authenticate){true}
    User.should_receive(:authenticate).with(params["user"])
    post '/session', params
  end
  
  context "with a valid user" do
    it "should create a cookie" do
      User.stub(:authenticate){true}
      post '/session', {"user" => {"login"=>"toto", "password" => "1234"}}
      last_response.headers["Set-Cookie"].should be_true
    end
    
    
    it "should redirect the user to /" do
      User.stub(:authenticate){true}
      post '/session', {"user" => {"login"=>"toto", "password" => "1234"}}
      follow_redirect!
      last_request.path.should == '/'
      last_response.body.should include("Bonjour toto")
    end
    
    it "should register the user into the current user_session" do
      User.stub(:authenticate){true}
      post '/session', {"user" => {"login"=>"toto", "password" => "1234"}}
      follow_redirect!
      last_request.env["rack.session"]["current_user"].should == "toto"
    end
    
  end

end






