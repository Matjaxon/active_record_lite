require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL)[0].map(&:to_sym)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    @columns
  end

  def self.finalize!

    columns.each do |col| #columns is a class method so this will properly be called.

      define_method(col) do  # instance scope so self will refer to instance of class
        self.attributes["#{col}".to_sym]
      end

      define_method("#{col}=") do |value| # instance scope so self will refer to instance of class
        self.attributes["#{col}".to_sym] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ? @table_name : ActiveSupport::Inflector.tableize(self.to_s)
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    self.parse_all(results)
  end

  def self.parse_all(results)
    result_objects = []
    results.each do | result |
      result_objects << self.new(result)
    end
    result_objects
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = #{id}
    SQL
    self.parse_all(results).first
  end

  def initialize(params = {})
    params.each do |k,v|
      raise "unknown attribute '#{k}'" unless self.class.columns.include?(k.to_sym)
      send("#{k}=", v)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    col_string = attributes.keys.map(&:to_s).join(", ")
    values_string = attribute_values.map{ |el|  "\'#{el}\'"}.join(", ")
    results = DBConnection.execute(<<-SQL)
      INSERT INTO
        #{self.class.table_name} (#{col_string})
      VALUES
        (#{values_string})
      SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    attributes_ex_id = attributes.reject{ |k,_| k == :id}
    update_string = attributes_ex_id.map{ |k, v| "#{k.to_s}=\'#{v.to_s}\'"}.join(",")
    results = DBConnection.execute(<<-SQL)
      UPDATE
        #{self.class.table_name}
      SET
        #{update_string}
      WHERE
        id = #{self.id}
      SQL
    self
  end

  def save
    self.id.nil? ? self.insert : self.update
  end
end
