require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/subdomain'
require 'haml'
require 'digest/md5'

config_file 'config.yml'

unless ENV['RACK_ENV'] == 'production'
  require 'dotenv'
  Dotenv.load
end

subdomain do
  get '/' do
    redirect "http://#{ENV["DOMAIN"]}" unless settings.subdomains.has_key? subdomain
    @resource = settings.subdomains[subdomain]
    expires (60*60*24), :public, :must_revalidate
    etag Digest::MD5.hexdigest(@resource.to_s)
    haml :resources
  end
  get '/theme.css' do
    @resource = settings.subdomains[subdomain]
    content_type 'text/css'
    %W(
      body {
        background-color: #{@resource["styling"]["bg_color"]};
        font-family: #{@resource["styling"]["font_family"]};
        color: #{@resource["styling"]["text_color"]};
      }
      header {
        background-color: #{@resource["styling"]["header"]["bg_color"]};
        color: #{@resource["styling"]["header"]["text_color"]};
      }
      .resource {
        background-color: #{@resource["styling"]["resource_block"]["background_color"]};
      }
    )
  end
end

get '/' do
  redirect "http://#{settings.subdomains.keys.shuffle.first}.#{ENV["DOMAIN"]}"
end
