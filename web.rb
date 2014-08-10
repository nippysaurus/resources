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
