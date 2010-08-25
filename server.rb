require 'rubygems'
require 'sinatra'
require 'session_login'
require 'aws/s3'
require 'digest'
require 'mime/types'
require 'uri'

required_config_vars = %W{BASE_HOSTNAME AMAZON_S3_ACCESS_KEY_ID AMAZON_S3_SECRET_ACCESS_KEY AMAZON_S3_BUCKET AMAZON_S3_PATH UPLOADER_USERNAME UPLOADER_PASSWORD}
missing = required_config_vars.reject{ |var| ENV[var] }
raise "The following environment vars were missing => #{missing.join(',')}" unless missing.empty?

set :username, ENV['UPLOADER_USERNAME']
set :password, ENV['UPLOADER_PASSWORD']

AWS::S3::Base.establish_connection!(
  :access_key_id     => ENV['AMAZON_S3_ACCESS_KEY_ID'],
  :secret_access_key => ENV['AMAZON_S3_SECRET_ACCESS_KEY']
)

BUCKET = ENV['AMAZON_S3_BUCKET']
BASE_PATH = ENV['AMAZON_S3_PATH']

get '/' do
  authorize!
  if params['url'] =~ URI.regexp
    upload_file
  else
    erb :index
  end
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
    redirect '/', 303
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
<h2>Instructions</h2>
<ol>
  <li>Drag <a href="<%= bookmarklet %>">grab image</a> to bookmarks bar</li>
  <li>Visit page you want an image from</li>
  <li>Click "grab image"</li>
  <li>Click on the image you want</li>
  <li>Done. The file has been added to s3 and you can use it wherever you like.</li>
</ol>



