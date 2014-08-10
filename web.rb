require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/subdomain'
require 'haml'

require 'dotenv'
Dotenv.load

config_file 'config.yml'

subdomain do
  get '/' do
    redirect "http://#{ENV["DOMAIN"]}" unless settings.subdomains.has_key? subdomain
    @resource = settings.subdomains[subdomain].inspect.to_s
    haml :resources
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
