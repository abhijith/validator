require_relative 'init'
require 'redis-queue'

class Kueue
  attr_accessor :queue, :redis

  def initialize(host: nil, port: nil)
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

class Unity
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
        queue.push(payload)
        true
      else
        UnityLogger.info("queue not initialized or is not reachable")
        false
      end
      true
    else
      UnityLogger.info("invalid payload #{payload}")
      false
    end
  end

end
