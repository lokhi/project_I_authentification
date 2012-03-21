require 'spec_helper'
require_relative '../appli1'
def app
  Sinatra::Application
end
ENV['RACK_ENV']='test'


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
    	before(:each) do
    	 @login="591r9civmBm7WDumkoao8Ji6Nd0i7RX31n2UtK5jezFSbchDJ-jQX5FXAPoClEAbNny5zTSkjlN6Ci7TvU9Dxi4mXhOPtI74vuK4gJNULyoDLcjYQm-ViB9at9nPI3sH7FaOkTfszAP3w1LH-fOAc867QH7L7uZZLQQQ5wrkeWI="
    	  @params={"login"=>@login, "secret"=>"123" }
    	  @session={"rack.session" => { "123" => Time.now.to_i }}
    	 @key="-----BEGIN RSA PRIVATE KEY-----
MIICXwIBAAKBgQDvqAuECzBu8JYrYleC245UZVyB3N11guYosh0fHaAstywPWblH
wq0es92nxEtp/qin051s+48/0lu1eKQnpfhRqOImxRhnyn9Vl7eR2Ssjg/yIhu+Q
1nQgAnviWa6ktFbKgnxayy4Jd2a0XDsnxDWr21bQmEbgekzzcZIEijHeLQIDAQAB
AoGBAKndvmvVUnsP5CDUD5sc7AE95xfU6NOF+IUX2jRX11RacMxgmEcY4YRFkPJ8
28dBTWHHSGoa1Co0e/RgklnX9ezsT5sYIcqH2CBw8p1U8o8182FcgIyd/4/3vuyq
Qbl6xJz0WpSkKVM8NGs03/ZczHW7MPvXzbok0V4WSHa5EbIxAkEA+30OEzsXcfBu
9bU8UpqfoApd5BwbnIDhizEucwMqWdm2b32/vLZGYeCCdMn+oxExQvb0A6or3jeW
gR2T+9yt6wJBAPP0pudcba2GMR1O0KrT8p2tN0Sez1+UKAG2vUkP72I8lBRzuKs8
Wyi0YYM2G7jsePdCkfTToQrbyhq4v9GWZkcCQQCexzC4wYkm3bcgmGFSgd8gKwtm
dryUDebYe5+o66m0erktIQaKPcaoCxgyZknHaJZiggpDug/iR9RVBnik/oorAkEA
3cnpC6JuXDoJ4PlMoGI8yrk16/7tzZlmndhDUm9YVVl5zvY+R/+BaQpFNQM2RPNI
LpOpGopkePjFT3HzglpX9QJBANm8xkkaGZQ76zbxIKMxWyyDY14wQ46RfFUtMD8i
6d/TDWlkVLVH4PszANlp1AmHvRyuCLSbkQA6NwLFRkBO6Ho=
-----END RSA PRIVATE KEY-----"
	File.stub(:read){@key}
	
    	end
    	
      it "should read the private key" do
        File.should_receive(:read).with("private.pem")
        get '/protected',@params , @session
      end
      
      it "should return the login" do
        get '/protected',@params , @session
        last_response.body.should include("Hello toto")
      end
    end
  end
end
