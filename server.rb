require 'rubygems'
require 'sinatra'
require 'aws/s3'
require 'digest'
require 'mime/types'

AWS::S3::Base.establish_connection!(
  :access_key_id     => ENV['MSD_AMAZON_S3_ACCESS_KEY_ID'],
  :secret_access_key => ENV['MSD_AMAZON_SECRET_ACCESS_KEY']
)

get '/' do
  erb :index
end

post '/' do
  filename = params['image'].gsub(/\?.*$/, '')
  type = MIME::Types.type_for(filename).first
  path = 'newsletters_demo/' + Digest::SHA1.hexdigest(params['image']) + '.' + type.extensions.first
  AWS::S3::S3Object.store(path, 
                 open(params['image']), 
                 ENV['MSD_IMAGES_BUCKET'],
                 :access => :public_read,
                 :content_type => type.to_s)
  url = "http://#{ENV['MSD_IMAGES_BUCKET']}.s3.amazonaws.com/" + path
  redirect url
end

__END__

@@ index

<h1>Image loader</h1>

<form method="post">
  <label>Image</label>
  <input name="image" type="text" />
  <input type="submit" value="Load" />
</form>

