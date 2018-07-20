require 'logger'

UnityLogger = Logger.new(STDOUT)
UnityLogger.level = ENV["LOG_LEVEL"] || Logger::INFO
