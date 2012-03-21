require 'crypteencode'

class DummyClassWithCrypteEncodeModule
  include CrypteEncode
end

describe DummyClassWithCrypteEncodeModule do

  describe "the cypher method" do
    before (:each) do
      @key="-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDvqAuECzBu8JYrYleC245UZVyB
3N11guYosh0fHaAstywPWblHwq0es92nxEtp/qin051s+48/0lu1eKQnpfhRqOIm
xRhnyn9Vl7eR2Ssjg/yIhu+Q1nQgAnviWa6ktFbKgnxayy4Jd2a0XDsnxDWr21bQ
mEbgekzzcZIEijHeLQIDAQAB
-----END PUBLIC KEY-----"
       @pubkey = double(OpenSSL::PKey::RSA)
       @pubkey.stub(:public_encrypt){"totoc"}
       OpenSSL::PKey::RSA.stub(:new){@pubkey}
    end
  
    it "should create the RSA pubkey with the key in parameter" do
      OpenSSL::PKey::RSA.should_receive(:new)
     subject.cypher(@key,"toto")
   end
  
   it "should encrypt the login" do
     @pubkey.should_receive(:public_encrypt).with("toto")
     subject.cypher(@key,"toto")
   end
   it "should encode the encrypted login" do
     Base64.should_receive(:urlsafe_encode64)
     subject.cypher(@key,"toto")
   end

  end
  
  describe "the decypher method" do
     before (:each) do
       Base64.stub(:urlsafe_decode64){"totocrypteddecoded"}
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
       @privkey = double(OpenSSL::PKey::RSA)
       @privkey.stub(:private_decrypt){"totoc"}
       OpenSSL::PKey::RSA.stub(:new){@privkey}
    end
    
    it "should decode the login in parameters" do
     Base64.should_receive(:urlsafe_decode64)
     subject.decypher(@key,"totocryptedencoded")
   end
   
   it "should create the rsa private key with the key in parameters" do
     OpenSSL::PKey::RSA.should_receive(:new){@privkey}
     subject.decypher(@key,"totocryptedencoded")
   end
   
   it "should decrypt the login with the privkey" do
     @privkey.should_receive(:private_decrypt)
     subject.decypher(@key,"totocryptedencoded")
   end
  end
  
end
