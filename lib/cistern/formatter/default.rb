module Cistern::Formatter::Default
  def self.call(obj)
    "#<%s:0x%x attributes={%s}>" % [obj.class, obj.object_id.abs*2, obj.attributes.map{|k,v| "#{k}:#{v.inspect}"}.join(",")]
  end
end
