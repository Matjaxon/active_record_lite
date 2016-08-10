require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  # TODO: This requires 2 queries to be called.  One to obtain the first
  # through object and another to obtain the source object.
  # This can be done in a single query by compiling a SQL query from the
  # 2 assoc_options.

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_object = self.send(through_name)
      source_object = through_object.send(source_name)
    end
  end
end
