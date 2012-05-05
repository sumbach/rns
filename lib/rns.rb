module Rns
  def self.included(base)
    base.extend(ClassMethods)
  end

  def self.add_methods(to, from, method_names)
    method_names.each do |name|
      to.send(:define_method, name) do |*args|
        from.method(name).call(*args)
      end
    end
  end

  module ClassMethods
    def include_specified(use_spec)
      Rns::to_pairs(use_spec).each do |pkg, method_names|
        Rns::add_methods(self, pkg, method_names)
      end
    end

    def extend_specified(use_spec)
      singleton_class = class << self; self; end
      Rns::to_pairs(use_spec).each do |pkg, method_names|
        Rns::add_methods(singleton_class, pkg, method_names)
      end
    end
  end

  def self.to_pairs(use_spec)
    case use_spec
    when Array then use_spec.each_slice(2).reduce([]){|xs,y| xs + [y]}
    when Hash then use_spec.to_a
    else
      raise "Don't know how to make module/class:methods pairs out of #{use_spec.class}"
    end
  end

  def self.populate(obj, use_spec)
    obj.tap do |o|
      to_pairs(use_spec).each do |pkg, method_names|
        Rns::add_methods(o.class, pkg, method_names)
      end
    end
  end

  def self.using(use_spec, &blk)
    blk[Rns::populate(Object.new, use_spec)]
  end
end
