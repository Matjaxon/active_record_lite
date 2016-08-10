require_relative '02_searchable'
require 'active_support/inflector'
# require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor :foreign_key, :class_name, :primary_key

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})

    defaults = {
      :foreign_key => "#{name}_id".to_sym,
      :primary_key => :id,
      :class_name => "#{name}".camelcase
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end

  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      :foreign_key => "#{self_class_name.to_s.downcase}_id".to_sym,
      :primary_key => :id,
      :class_name => "#{name}".camelcase.singularize
    }

    # Longhand version of the self.send("#{keys}=", ...) method above
    self.primary_key = options[:primary_key] ||= defaults[:primary_key]
    self.foreign_key = options[:foreign_key] ||= defaults[:foreign_key]
    self.class_name =  options[:class_name]  ||= defaults[:class_name]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    define_method (name) do
      foreign_key_value = self.send(options.foreign_key)
      options.model_class.where(id: foreign_key_value).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)
    define_method(name) do
      foreign_key_value = self.id
      options.model_class.where(options.foreign_key => foreign_key_value)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
  # Mixin Associatable here...
end
