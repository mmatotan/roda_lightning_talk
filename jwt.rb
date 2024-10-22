class Jwt
  require 'json'
  require 'openssl'
  require 'base64'

  attr_accessor :token, :encoded_header, :encoded_payload, :signature

  @@header = {
    'typ': 'JWT',
    'alg': 'HS256'
  }

  @@key = 'NTNv7j0TuYARvmNMmWXo6fKvM4o6nv/aUi9ryX38ZH+L1bkrnD1ObOQ8JAUmHCBq7Iy7otZcyAagBLHVKvvYaIpmMuxmARQ97jUVG16Jkpkp1wXOPsrF9zwew6TpczyHkHgX5EuLg2MeBuiT/qJACs1J0apruOOJCg/gOtkjB4c='

  def initialize(token)
    @token = token.split.last
    return unless token

    @encoded_header, @encoded_payload, @signature = token.split('.')
  end

  def self.create_from_payload(payload)
    encoded_header = encode(@@header.to_json)
    encoded_payload = encode(payload.to_json)
    decoded_key = decode(@@key)
    combined = "#{encoded_header}.#{encoded_payload}"
    signature = encode(OpenSSL::HMAC.digest('SHA256', decoded_key, combined))

    new("Bearer #{[encoded_header, encoded_payload, signature].join('.')}")
  end

  def valid?
    return false if Time.now.to_i > payload[:exp]

    new_token = self.class.create_from_payload(payload)
    new_token.signature == signature
  end

  def payload
    JSON.parse(self.class.decode(encoded_payload), symbolize_names: true)
  end

  def self.encode(data)
    Base64.urlsafe_encode64(data).gsub('=', '')
  end

  def self.decode(data)
    Base64.urlsafe_decode64(data)
  end
end
