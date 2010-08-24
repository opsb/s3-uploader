require 'rubygems'
require 'sinatra'
require 'aws/s3'
require 'digest'
require 'mime/types'
require 'uri'

AWS::S3::Base.establish_connection!(
  :access_key_id     => ENV['AMAZON_S3_ACCESS_KEY_ID'],
  :secret_access_key => ENV['AMAZON_S3_SECRET_ACCESS_KEY']
)

use Rack::Auth::Basic do |username, password|
  [username, password] == [ENV['UPLOADER_USERNAME'], ENV['UPLOADER_PASSWORD']]
end

BUCKET = ENV['AMAZON_S3_PATH']

get '/' do
  erb :index
end

post '/' do
  if params['url'] =~ URI.regexp
    AWS::S3::S3Object.store( path,
                             open(params['url']), 
                             BUCKET,
                             :access => :public_read,
                             :content_type => content_type )
    redirect amazon_url
  else
    redirect '/'
  end
end

def content_type
  filename = params['url'].gsub(/\?.*$/, '')
  type = MIME::Types.type_for(filename).first
end

def path
  BUCKET + Digest::SHA1.hexdigest(params['url']) + '.' + content_type.extensions.first
end

def amazon_url
  "http://#{BUCKET}.s3.amazonaws.com/#{path}"
end

__END__

@@ index

<h1>Amazon uploader</h1>

<form method="post">
  <label>File</label>
  <input name="url" type="text" />
  <input type="submit" value="Load" />
</form>

