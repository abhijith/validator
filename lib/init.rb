require 'json'
require 'pp'
require 'logger'

UnityLogger = Logger.new
UnityLogger.level = ENV["LOG_LEVEL"] || Logger::INFO
