module GitRecord
  class HashType < ActiveModel::Type::Value
    def cast(value)
      return super unless value.is_a? Hash
  
      struct = OpenStruct.new(value)

      super(value)
    end
  end
end

ActiveModel::Type.register(:hash, GitRecord::HashType)
