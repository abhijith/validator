class UnityError < StandardError
  def initialize(x = nil)
    UnityLogger.error(x) if x
    UnityLogger.debug(self.backtrace.join("\n")) if self.backtrace
  end
end

class InvalidPayload < UnityError ; end
