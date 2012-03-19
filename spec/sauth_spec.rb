require 'spec_helper'
require_relative '../sauth'
def app
  Sinatra::Application
end

describe "accessing to the homepage" do
  context "without being connected" do
    it "should redirect the user to /session/new" do
      get '/'
      follow_redirect!
      last_request.path.should == '/session/new'
    end
  end 
  
  context "with being connected" do
    it "should print the home page of the user" do
      u=double(User)
      User.stub(:find_by_login){u}
      u.stub(:login){"toto"}
      get '/',{},"rack.session" => { "current_user" => "toto" }
      last_response.body.should include("Hello toto")
    end
    
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
      last_request.path.should == '/session/new'
    end
  end
  
  context "with invalid parameters" do
    it "should print the register page" do
      erro=double("errors")
      @user.stub(:save){false}
      @user.stub(:login){"testrspec"}
      @user.stub(:errors){erro}
      erro.stub(:full_messages)
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
      u=double(User)
      User.stub(:find_by_login){u}
      u.stub(:login){"toto"}
      post '/session', @params
      follow_redirect!
      last_request.path.should == '/'
      last_response.body.should include("Hello toto")
    end
    
    it "should register the user into the current user_session" do
      post '/session', @params
      follow_redirect!
      last_request.env["rack.session"]["current_user"].should == "toto"
    end
  end
  
  context "with an invalid user" do
    it "should return the auth form" do
      u=double(User)
      User.stub(:authenticate){false}
      User.stub(:new){u}
      u.stub(:login){"toto"}
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
      get '/appli/new', {}, "rack.session" => { "current_user" => "toto" }
      last_response.should be_ok
      last_response.body.should include("<title>Application register</title>")
    end
    
    context "params are valid" do
    before(:each) do
      @appli.stub(:save){true}
    end
    it "should create an application" do
      Application.should_receive(:new)
      post '/appli', @params,"rack.session" => { "current_user" => "toto" }
    end
    
     it "should save the application" do
      @appli.should_receive(:save)
      post '/appli', @params,"rack.session" => { "current_user" => "toto" }
    end
    
    it "should redirect the user to the home page" do
      post '/appli', @params,"rack.session" => { "current_user" => "toto" }
      follow_redirect!
      last_request.path.should == "/"
    end
  end
    context "invalid params" do
      it "should return the application registration form" do
        @appli.stub(:name){"appli1"}
        @appli.stub(:adresse){"http://appli1.com"}
        @appli.stub(:key){"123"}
        erro=double("errors")
        @appli.stub(:errors){erro}
        erro.stub(:full_messages)
        @appli.stub(:save){false}
        post '/appli', @params,"rack.session" => { "current_user" => "toto" }
        last_response.should be_ok
        last_response.body.should include("<title>Application register</title>")
      end
    end
  end
end

describe "authentification of an user call by an application" do
  context "the user is connect to the sauth" do
  
    it "should use the encryption of the login by the application" do
      Application.should_receive(:generate_link)
      get '/appli1/session/new' , {"origin"=>"/protected","secret"=>"foo"},"rack.session" => { "current_user" => "toto" }
    end
    
    
    it "should redirect to the origin page off application" do
      Application.stub(:generate_link){"http://appli/protected?login=totocrypted&secret=secret"}
      get '/appli1/session/new' , {"origin"=>"/protected","secret"=>"foo"},"rack.session" => { "current_user" => "toto" }
      follow_redirect!
      last_request.url.should include("http://appli/protected")
    end
    
  end

  context "the user is not connect to the sauth" do
    it "should return the login form" do
    	get '/appli1/session/new' , {"origin"=>"/protected","secret"=>"foo"}
    	last_response.body.should include("<title>appli1 - login</title>")
    end
    
    context "params are valid" do
      before(:each)do
        @u=double(User)
        @u.stub(:login){"toto"}
        @u.stub(:id)
        User.stub(:authenticate){@u}
        Application.stub(:generate_link){"http://appli/protected?login=totocrypted&secret=secret"}
        @params={"user"=>{"login"=>"toto","password"=>"1234"},"origin"=>"/protected","secret"=>"foo"}
        @us=double(Use)
        @us.stub(:application_id)
        @us.stub(:user_id)
      end
    
    
      it "should use the user appli_authentification" do
        User.should_receive(:authenticate).with(@params["user"])
        post '/appli1/session', @params
      end
      
      it "should save that the user use this application" do
        Use.should_receive(:new)
         post '/appli1/session', @params
      end
      
      it "should use the encryption of the login by application" do
        Application.should_receive(:generate_link)
        post '/appli1/session', @params
      end
      
      it "should redirect to the origin application" do
        post '/appli1/session',@params
        follow_redirect!
        last_request.url.should == "http://appli/protected?login=totocrypted&secret=secret"
        
      end
 
    end
    
   
  end
end



describe "the admin part" do

  it "should be accessible only with the admin login" do
    User.stub(:authenticate){true}
    post '/session', {"user"=>{"login"=>"admin","password"=>"1234"}}
    follow_redirect!
    last_response.body.should include("Administration")
  end
  
  context "connect as admin" do
    it "should list all users of the sauth" do
      get '/admin',{},"rack.session" => { "current_user" => "admin" }
      last_response.body.should include("List of users")
       last_response.body.should include("List of applications")
    end
    
    it "should delete an user" do
      u=double("user")
      User.stub(:find_by_login){u}
      u.stub(:destroy)
      User.should_receive(:find_by_login).with("toto")
      u.should_receive(:destroy)
      get '/admin/users/toto/destroy'
    end 
    
 
    
    it "should delete an application" do
      a=double("appli")
      Application.stub(:find_by_name){a}
      a.stub(:destroy)
      Application.should_receive(:find_by_name).with("appli1")
      a.should_receive(:destroy)
      get '/admin/appli/appli1/destroy'
    end 
  end
end


describe "delete application on the user page" do
  it "should get the user corresponding to the current user" do
    User.should_receive(:find_by_login)
    get '/appli/app1/destroy',{},"rack.session" => { "current_user" => "toto" }
  end
end

