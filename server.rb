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

get '/' do
  erb :index
end

post '/' do
  if params['url'] =~ URI.regexp
    filename = params['url'].gsub(/\?.*$/, '')
    type = MIME::Types.type_for(filename).first
    path = ENV['AMAZON_S3_PATH'] + Digest::SHA1.hexdigest(params['url']) + '.' + type.extensions.first
    AWS::S3::S3Object.store(path,
                   open(params['url']), 
                   ENV['AMAZON_S3_BUCKET'],
                   :access => :public_read,
                   :content_type => type.to_s)
    url = "http://#{ENV['AMAZON_S3_BUCKET']}.s3.amazonaws.com/" + path
    redirect url
  else
    redirect '/'
  end
end

__END__

@@ index

<h1>Amazon uploader</h1>

<form method="post">
  <label>File</label>
  <input name="url" type="text" />
  <input type="submit" value="Load" />
</form>

