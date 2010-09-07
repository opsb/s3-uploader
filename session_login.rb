require 'sinatra/base'

enable :inline_templates

use Rack::Session::Cookie, :expire_after => 31536000

module Sinatra
  module SessionAuth

    module Helpers
      def authorized?
        session[:authorized]
      end

      def authorize!
        redirect '/login' unless authorized?
      end

      def logout!
        session[:authorized] = false
      end
    end

    def self.registered(app)
      app.helpers SessionAuth::Helpers

      app.set :username, 'frank'
      app.set :password, 'changeme'

      app.get '/login' do
        erb :login
      end

      app.post '/login' do
        if params[:user] == options.username && params[:pass] == options.password
          session[:authorized] = true
          redirect '/'
        else
          session[:authorized] = false
          redirect '/login'
        end
      end
    end
  end

  register SessionAuth
end

__END__

@@login
<h1>Login</h1>
<form method='POST' action='/login'>
  <label>Username</label>
  <input type='text' name='user'>
  <br />
  <label>Password</label>
  <input type='text' name='pass'>
  <br />  
  <input type='submit' value="Login" />
  <br />
</form>