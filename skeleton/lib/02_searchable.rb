require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{stringify_params(params)}
      SQL
    self.parse_all(results)
  end

  def stringify_params(params)
    params.map{ |k, v| "#{k.to_s}=\'#{v.to_s}\'"}.join(" AND ").delete(";")
  end
end

class SQLObject
  extend Searchable
  # Mixin Searchable here...
end
