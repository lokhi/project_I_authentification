require 'spec_helper'
require_relative '../sauth'
def app
  Sinatra::Application
end
ENV['RACK_ENV']='test'

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
      tab=double("tab")
      @user.stub(:save){false}
      @user.stub(:login){"testrspec"}
      @user.stub(:errors){erro}
      erro.stub(:full_messages){tab}
      tab.stub(:join)
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
      last_request.env["rack.session"]["current_user"].should be_true
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
    @u=double(User)
    User.stub(:find_by_login){@u}
    @u.stub(:id){1}
    @session={"rack.session" => { "current_user" => @u }}
  end
    
    it "should return the form to the application registeration" do
      get '/appli/new', {},@session
      last_response.should be_ok
      last_response.body.should include("<title>Application register</title>")
    end
    
    context "params are valid" do
    before(:each) do
      @appli.stub(:save){true}
    end
    it "should create an application" do
      Application.should_receive(:new)
      post '/appli', @params,@session
    end
    
     it "should save the application" do
      @appli.should_receive(:save)
      post '/appli', @params,@session
    end
    
    it "should redirect the user to the home page" do
      post '/appli', @params,@session
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
        tab=double("tab")
        erro.stub(:full_messages){tab}
        tab.stub(:join)
        @appli.stub(:save){false}
        post '/appli', @params,@session
        last_response.should be_ok
        last_response.body.should include("<title>Application register</title>")
      end
    end
  end
end

describe "authentification of an user call by an application" do
  before(:each)do
    @u=double(User)
    User.stub(:find_by_login){@u}
    User.stub(:authenticate){@u}
    @u.stub(:login){"toto"}
    @u.stub(:use)
    @a=double(Application)
    Application.stub(:find_by_name){@a}
    @a.stub(:name){"appli1"}
    @a.stub(:id)
    Application.stub(:generate_link){"http://appli1/protected?login=totocrypted&secret=secret"}
    @params={"origin"=>"/protected","secret"=>"foo"}
    @session={"rack.session" => { "current_user" => @u }}
  end
  
  
  context "the user is connect to the sauth" do
  
    context "it's the first time than the user use this application" do
      it "should ask at the user if he wants use his account" do
        @u.stub(:use?){false}
        get '/appli1/session/new' ,@params ,@session
        last_response.body.should include("<title>Continue with this login?</title>")
      end
      
      
      describe "the user decide to continue" do
        it "should record that the user use this app" do
          @u.should_receive(:use)
          get '/appli1/session/continue',@params ,@session
        end
        
        it "should use the generate link off Application" do
           Application.should_receive(:generate_link)
           get '/appli1/session/continue' , @params ,@session
        end
        
        it "should redirect the user to the app" do
          get '/appli1/session/continue' , @params ,@session
          follow_redirect!
          last_request.url.should include("http://appli1/protected")
        end
      end
      
      
      describe "the user create a new account" do
        before (:each) do
          @user=double(User)
          User.stub(:new){@user}
          @user.stub(:login){"testrspec"}
          @user.stub(:use)
          @params={"user" => {"login"=>"testrspec", "password"=>"1234"}}
        end
        
        it "should create a new user" do
          User.should_receive(:new)
          post '/appli1/user',@params
        end
        
        it "should save the user" do
          @user.should_receive(:save)
          post '/appli1/user',@params
        end
        
        context "params are good" do
          before(:each) do
            @user.stub(:save){true}
          end
          
          it "should record that the user use this app" do
            @user.should_receive(:use)
            post '/appli1/user',@params
          end
          
          it "should register the user into the current user_session" do
            post '/appli1/user',@params
            last_request.env["rack.session"]["current_user"].should == "testrspec"
          end
          
          it "should generate the redirect link with Application" do
            Application.should_receive(:generate_link)
            post '/appli1/user',@params
          end
          
          it "should redirect the user to  the app" do
            post '/appli1/user',@params
            follow_redirect!
            last_request.url.should include("http://appli1/protected")
          end
        end  
        
        context "params are not good" do
          it "should reprint the form" do
            @user.stub(:save){false}
            erro=double("errors")
            tab=double("tab")
            @user.stub(:save){false}
            @user.stub(:login){"testrspec"}
            @user.stub(:errors){erro}
            erro.stub(:full_messages){tab}
            tab.stub(:join)
            post '/appli1/user',{"user" => {"login"=>"testrspec", "password"=>"1234"}}
            last_response.body.should include("<title>Continue with this login?</title>")
          end
        end
      
      end
      
      
      
      
    end  
    
    context "it's not the first time than the user use this application" do
      before(:each) do
       @u.stub(:use?){true}
       @params={"origin"=>"/protected","secret"=>"foo"}
       @session={"rack.session" => { "current_user" => @u }}
      end
      
      it "should use the encryption of the login by the application" do
        Application.should_receive(:generate_link)
        get '/appli1/session/new' , @params, @session
      end
  
      it "should redirect to the origin page off application" do
        get '/appli1/session/new' ,  @params, @session
        follow_redirect!
        last_request.url.should include("http://appli1/protected")
      end
    end
    
  end

  context "the user is not connect to the sauth" do
  
    it "should return the login form" do
    	get '/appli1/session/new' , {"origin"=>"/protected","secret"=>"foo"}
    	last_response.body.should include("<title>appli1 - login</title>")
    end
    
    context "params are valid" do
      before(:each)do
        @params={"user"=>{"login"=>"toto","password"=>"1234"},"origin"=>"/protected","secret"=>"foo"}
      end
    
    
      it "should use the user appli_authentification" do
        User.should_receive(:authenticate).with(@params["user"])
        post '/appli1/session', @params
      end
      
      it "should save that the user use this application" do
        @u.should_receive(:use)
        post '/appli1/session', @params
      end
      
      it "should use the encryption of the login by application" do
        Application.should_receive(:generate_link)
        post '/appli1/session', @params
      end
      
      it "should redirect to the origin application" do
        post '/appli1/session',@params
        follow_redirect!
        last_request.url.should == "http://appli1/protected?login=totocrypted&secret=secret"
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
    before(:each) do
      @u=double(User)
      @admin=double(User)
      @admin.stub(:admin?){true}
      User.stub(:find_by_login){@u}
      @u.stub(:destroy)
    end
    it "should list all users of the sauth" do
      get '/',{},"rack.session" => { "current_user" => @admin }
      last_response.body.should include("List of users")
       last_response.body.should include("List of applications")
    end
    
    it "should delete an user" do
      User.should_receive(:find_by_login).with("toto")
      @u.should_receive(:destroy)
      get '/user/toto/destroy',{},"rack.session" => { "current_user" => @admin }
    end 
    
 
    
    it "should delete an application" do
      a=double("appli")
      Application.stub(:find_by_name){a}
      a.stub(:destroy)
      Application.should_receive(:find_by_name).with("appli1")
      a.should_receive(:destroy)
      get '/appli/appli1/destroy',{},"rack.session" => { "current_user" => @admin }
    end 
  end
end


describe "delete application on the user page" do
  it "should get the user corresponding to the current user" do
    app=double(Application)
    Application.stub(:find_by_name){app}
    u=double(User)
    u.stub(:admin?){false}
    app.stub(:user_id)
    u.should_receive(:id)
    get '/appli/app1/destroy',{},"rack.session" => { "current_user" => u }
  end
end

describe "page who not exists" do
  it "should return the 404 page" do
    get '/notexists'
    last_response.body.should include ("<title>404</title>")
  end
end

