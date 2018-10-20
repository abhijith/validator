require 'logger'

AppLogger = Logger.new(STDOUT)
AppLogger.level = ENV["LOG_LEVEL"] || Logger::INFO
STDOUT.sync = true
