require_relative 'init'
require 'redis-queue'

class Kueue
  attr_accessor :queue, :redis

  def initialize(host: nil, port: nil)
    AppLogger.info "host: #{host} port: #{port}"

    if host and port
      @redis = Redis.new(host: host, port: port)
      @queue = Redis::Queue.new('source','sink',  :redis => redis)
    else
      @redis = nil
    end
  end

  def inited?
    not (queue.nil? or redis.nil?)
  end

  def pings?
    begin
      redis.ping == "PONG"
    rescue Redis::CannotConnectError => e
      false
    end
  end

  def ready?
    inited? and pings?
  end

  def flush
    redis.flushall if ready?
  end

  def push(x)
    queue.push(x)
  end

end

class App
  attr_accessor :schema, :queue

  def initialize(schema, host: nil, port: nil)
    @schema = schema
    if host and port
      @queue = Kueue.new(host: host, port: port)
    end

    self
  end

  def flush
    queue.flush if ready?
  end

  def alive?
    true
  end

  def ready?
    queue.ready?
  end

  def process(payload)
    if payload_valid?(schema, payload)
      if ready?
        AppLogger.info("En-queuing payload: #{payload}")
        queue.push(payload)
        AppLogger.info("Enqueued payload: #{payload}")

        true
      else
        AppLogger.error("Queue not initialized or is not reachable")
        false
      end
      true
    else
      AppLogger.info("Invalid payload: #{payload}")
      false
    end
  end

end
