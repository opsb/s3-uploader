require 'rubygems'
require 'sinatra'
require 'aws/s3'
require 'digest'
require 'mime/types'
require 'uri'

required_config_vars = %W{BASE_HOSTNAME AMAZON_S3_ACCESS_KEY_ID AMAZON_S3_SECRET_ACCESS_KEY AMAZON_S3_BUCKET AMAZON_S3_PATH UPLOADER_USERNAME UPLOADER_PASSWORD}
missing = required_config_vars.reject{ |var| ENV[var] }
raise "The following environment vars were missing => #{missing.join(',')}" unless missing.empty?

AWS::S3::Base.establish_connection!(
  :access_key_id     => ENV['AMAZON_S3_ACCESS_KEY_ID'],
  :secret_access_key => ENV['AMAZON_S3_SECRET_ACCESS_KEY']
)

use Rack::Auth::Basic do |username, password|
  [username, password] == [ENV['UPLOADER_USERNAME'], ENV['UPLOADER_PASSWORD']]
end

BUCKET = ENV['AMAZON_S3_BUCKET']
BASE_PATH = BUCKET + '/' + ENV['AMAZON_S3_PATH']

get '/' do
  if params['url'] =~ URI.regexp
    upload_file
  else
    erb :index
  end
end

post '/' do
  upload_file
end

def upload_file
  if params['url'] =~ URI.regexp
    AWS::S3::S3Object.store( path,
                             open(params['url']), 
                             BUCKET,
                             :access => :public_read,
                             :content_type => get_content_type.to_s)
    redirect amazon_url
  else
    redirect '/'
  end  
end

def get_content_type
  filename = params['url'].gsub(/\?.*$/, '')
  type = MIME::Types.type_for(filename).first
end

def path
  BASE_PATH + Digest::SHA1.hexdigest(params['url']) + '.' + extension
end

def extension
  get_content_type.extensions.first
end

def amazon_url
  "http://#{BUCKET}.s3.amazonaws.com/#{path}"
end

def bookmarklet
  js = File.open('bookmarklet.js').read.
            gsub("<%= base_hostname %>", ENV['BASE_HOSTNAME'])
  
  compile_bookmarklet(js)
end

def compile_bookmarklet(javascript)
  javascript.gsub(/\s+/,' ').
             gsub(/\n/,'').
             gsub(/;\s*[^\w]/, ';').
             gsub(/'/, '%27').
             gsub(/"/, '%22').
             gsub(/^\s*/, '').
             gsub(/\s/, '%20')
end

__END__

@@ index

<h1>Amazon uploader</h1>

<a href="<%= bookmarklet %>">bookmarklet</a>

<form method="post">
  <label>File</label>
  <input name="url" type="text" />
  <input type="submit" value="Load" />
</form>

