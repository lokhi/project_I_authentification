require 'spec_helper'
require_relative '../sauth'

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
    it "should save the user" do
       @user.stub(:save){true}
       @user.should_receive(:save)
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
   before(:each) do
     @params={"user" => {"login"=>"toto", "password"=>"1234"}}
   end

  it "should use the user authentification" do
    User.should_receive(:authenticate).with(@params["user"])
    post '/session', @params
  end
  
  context "with a valid user" do
   before(:each) do
     User.stub(:authenticate){true}
   end
    it "should create a cookie" do
      
      post '/session', @params
      last_response.headers["Set-Cookie"].should be_true
    end
    
    
    it "should redirect the user to /" do
      post '/session', @params
      follow_redirect!
      last_request.path.should == '/'
      last_response.body.should include("Bonjour toto")
    end
    
    it "should register the user into the current user_session" do
      post '/session', @params
      follow_redirect!
      last_request.env["rack.session"]["current_user"].should == "toto"
    end
  end
  
  context "with an invalid user" do
    it "should return the auth form" do
      User.stub(:authenticate){false}
      post '/session', @params
      last_response.body.should include("<title>login page</title>")
    end
  end
end


describe "registration of an application by an user" do
  context "the user is connected" do
  before(:each) do
    @params={"appli" => {"name"=>"appli1", "adresse"=>"http://appli1.com"}}
    @appli = double ("appli")
    Application.stub(:new){@appli}
  end
    
    it "should return the form to the application registeration" do
      get '/appli/new'
      last_response.should be_ok
      last_response.body.should include("<title>Application register</title>")
    end
    
    context "params are valid" do
    before(:each) do
      @appli.stub(:save){true}
    end
    it "should create an application" do
      Application.should_receive(:new).with(@params["appli"])
      post '/appli', @params
    end
    
     it "should save the application" do
      @appli.should_receive(:save)
      post '/appli', @params
    end
    
    it "should redirect the user to the application page" do
      post '/appli', @params
      follow_redirect!
      last_request.path.should == "/appli/appli1"
      last_response.body.should include("application appli1")
    end
  end
    context "invalid params" do
      it "should return the application registration form" do
        @appli.stub(:save){false}
        post '/appli', @params
        last_response.should be_ok
        last_response.body.should include("<title>Application register</title>")
      end
    end
  end
end

describe "authentification of an user call by an application" do
  context "the user is not connect to the sauth" do
    it "should return the login form" do
    	get '/appli1/session/new' , {"origin"=>"/protected","secret"=>"foo"}
    	last_response.body.should include("appli1 login page")
    end
    
    context "params are valid" do
      before(:each)do
        User.stub(:authenticate){true}
      end
    
      it "should use the user authentification" do
        params={"user"=>{"login"=>"toto","password"=>"1234"},"origin"=>"/protected","secret"=>"foo"}
        User.should_receive(:authenticate).with(params["user"])
        post '/appli1/session', params
      end
      
      it "should register the user into the current user_session" do
        post '/appli1/session',{"user"=>{"login"=>"toto","password"=>"1234"},"origin"=>"/protected","secret"=>"foo"}
        last_request.env["rack.session"]["current_user"].should == "toto"
      end
      
      
      #it "should redirect to the origin application" do
      #  post '/appli1/session',{"user"=>{"login"=>"toto","password"=>"1234"},"origin"=>"/protected","secret"=>"foo"}
      #  follow_redirect!
      #  last_request.should be_ok
      #end
      #it "should record that user use this application" do
        
      #end
    end
    
   
  end
end


