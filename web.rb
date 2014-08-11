require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/subdomain'
require 'haml'

config_file 'config.yml'

unless ENV['RACK_ENV'] == 'production'
  require 'dotenv'
  Dotenv.load
end

subdomain do
  get '/' do
    redirect "http://#{ENV["DOMAIN"]}" unless settings.subdomains.has_key? subdomain
    @resource = settings.subdomains[subdomain]
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
      .resource:hover {
        background-color: #{@resource["styling"]["resource_block"]["background_hover_color"]};
      }
    )
  end
end

get '/' do
  @resources = settings.subdomains.keys.map do |key|
    {
      name: key,
      url: "http://#{key}.#{ENV["DOMAIN"]}"
    }
  end

  haml :index
end
