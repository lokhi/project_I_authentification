require 'crypteencode'

class DummyClassWithCrypteEncodeModule
  include CrypteEncode
end

describe DummyClassWithCrypteEncodeModule do
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
