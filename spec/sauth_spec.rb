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
    get '/user/new'
    last_response.should be_ok
  end
 
  context "login and password are valid" do
   after(:each) do
     u = User.find_by_login("testrspec")
     u.destroy
   end
    it "should redirect to the login page" do
      post '/user', params={:login=>"testrspec",:password=>"1234"}
      follow_redirect!
      last_request.path.should == '/login'
    end
  end
  
   context "login and password are invalid" do
     it "should redirect to the register page" do
       post '/user', params={:login=>"",:password=>"1234"}
      follow_redirect!
      last_request.path.should == '/user/new'
     end
     
     it "should return an error message" do
        post '/user', params={:login=>"",:password=>"1234"}
        follow_redirect!
        last_request.GET.should ==  {"r"=>"error"}
     end
     
     it "should print to the register page a error message" do
       post '/user', params={:login=>"",:password=>"1234"}
       follow_redirect!
       last_response.body.should include('login or password invalid')
     end
   end
end






