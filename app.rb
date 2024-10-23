# frozen_string_literal: true

require 'roda'
require_relative 'jwt'

class App < Roda
  plugin :request_headers

  route do |r|

    # /
    r.root do
      'hello world!'
    end

    puts 'in the router'

    # /login
    r.post 'login' do
      jwt = Jwt.create_from_payload({ username: 'Kodius', exp: 1729971750 })
      jwt.token
    end

    r.on 'user' do
      set_bearer_token(r)
      unless @jwt.valid? 
        response.status = 401
        next 'Unauthorized!'
      end

      puts 'set token and authorized!'

      # /user
      r.get true do
        puts 'printing out the username!'
        @jwt.payload[:username]
      end

      # /user/edit
      r.post 'edit' do
        puts 'editing the user!'
        'user edited!'
      end

    end
  end

  private

  def set_bearer_token(r)
    @jwt = Jwt.new(r.headers['Authorization'])
  end

end
