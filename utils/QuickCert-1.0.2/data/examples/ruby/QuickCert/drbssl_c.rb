#!/usr/bin/env ruby

require 'drb'
require 'drb/ssl'

send_cert = true
there = ARGV.shift || "drbssl://localhost:3456"

config = Hash.new
config[:SSLVerifyMode] = OpenSSL::SSL::VERIFY_PEER
config[:SSLCACertificateFile] = "cacert.pem"
config[:SSLVerifyCallback] = lambda { |ok, store|
  p [ok, store.error_string]
  ok
}

if send_cert then
  config[:SSLPrivateKey] = OpenSSL::PKey::RSA.new File.read("drbrain_keypair.pem")
  config[:SSLCertificate] = OpenSSL::X509::Certificate.new File.read("cert_drbrain.pem")
end

DRb.start_service(nil,nil,config)
h = DRbObject.new(nil, there)
while line = gets
  p h.hello(line.chomp)
end
