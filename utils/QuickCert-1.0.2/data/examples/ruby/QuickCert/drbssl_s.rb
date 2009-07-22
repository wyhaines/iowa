#!/usr/bin/env ruby

require 'drb'
require 'drb/ssl'

require_client_cert = true
here = ARGV.shift || "drbssl://localhost:3456"

class HelloWorld
  include DRbUndumped

  def hello(name)
    "Hello, #{name}."
  end
end

config = Hash.new
config[:verbose] = true
config[:SSLPrivateKey] = OpenSSL::PKey::RSA.new File.read("uriel_keypair.pem")
config[:SSLCertificate] =
  OpenSSL::X509::Certificate.new File.read("cert_uriel.pem")

if require_client_cert then
  config[:SSLVerifyMode] = OpenSSL::SSL::VERIFY_PEER |
                           OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
  config[:SSLCACertificateFile] = "cacert.pem"
  config[:SSLVerifyCallback] = proc do |ok, store|
    p [ok, store.error_string]
    ok
  end
end

DRb.start_service(here, HelloWorld.new, config)
puts DRb.uri
DRb.thread.join
