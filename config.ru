require 'rubygems'
require 'bundler'

Bundler.require
require './rest_interface'
run Sinatra::Application
