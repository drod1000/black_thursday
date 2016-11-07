require 'time'

class Customer
  attr_reader   :id,
                :first_name,
                :last_name,
                :created_at,
                :updated_at,
                :parent

  def initialize(hash, parent=nil)
    @id = hash[:id].to_i
    @first_name = hash[:first_name]
    @last_name = hash[:last_name]
    @created_at = Time.parse(hash[:created_at])
    @updated_at = Time.parse(hash[:updated_at])
    @parent = parent
  end
end
