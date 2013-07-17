# Originally by Jeff Gardner

class String
  def to_b
    return true if self == true || self =~ (/(true|t|yes|y|1|on)$/i)
    return false if self == false || self.blank? || self =~ (/(false|f|no|n|0|off)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end
