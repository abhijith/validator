require_relative 'init'
require 'redis-queue'

class Unity

  attr_accessor :schema, :queue, :redis

  def initialize(schema, host: nil, port: nil)
    @schema = schema
    if host and port
      @redis = Redis.new(host: host, port: port)
      @queue = Redis::Queue.new('source','sink',  :redis => redis)
    else
      @redis = nil
    end

    self
  end

  def flush
    redis.flushall if ready?
  end

  def queue_inited?
    not (queue.nil? or redis.nil?)
  end

  def alive?
    true
  end

  def queue_ready?
    begin
      redis.ping == "PONG"
    rescue Redis::CannotConnectError => e
      UnityLogger.info("queue not ready")
      false
    end
  end

  def ready?
    queue_inited? and queue_ready?
  end

  def process(payload)
    if payload_valid?(schema, payload)
      if ready?
        queue.push(payload)
        true
      else
        false
      end
      true
    else
      UnityLogger.info("invalid payload #{payload}")
      false
    end
  end

end
