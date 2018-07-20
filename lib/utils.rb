class String
  def int?
    self.to_i.to_s == self
  end
end
