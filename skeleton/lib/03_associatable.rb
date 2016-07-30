require_relative '02_searchable'
require 'active_support/inflector'
# require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    Object::const_get(@name.classify)  #Finds the existing class if it exsits.
  end

  def foreign_key
    foreign_key_string = ActiveSupport::Inflector.underscore(@name)
    @options[:foreign_key] ||= "#{foreign_key_string}_id".to_sym
  end

  def primary_key
    @options[:primary_key] ||= "id".to_sym
  end

  def class_name
    class_name_string = ActiveSupport::Inflector.classify(@name)
    @options[:class_name] ||= class_name_string
  end

  def table_name
    model_class.table_name ||= ActiveSupport::Inflector.tableize(@name)
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @name = name
    @options = options
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    self_class_options = BelongsToOptions.new(self_class_name, options)

    @name = name
    @options = options

    @options[:primary_key] ||= self_class_options.primary_key
    @options[:foreign_key] ||= self_class_options.foreign_key
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    p options
    p options.model_class
    # p self
    # define_method "#{name}" do
    #   options.class_name.model_class.where()
    # end
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
  # Mixin Associatable here...
end
