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






