module GitRecord
  class BaseRepository 
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :name
    attribute :full_name
    attribute :url

    define_model_callbacks :create, :update, :destroy, :initialize

    def initialize(**attributes)
      super
    end
  end
end