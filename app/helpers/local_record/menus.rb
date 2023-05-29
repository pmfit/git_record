# frozen_string_literal: true

module LocalRecord
  module Menus
    def menus(document_model)
      raise ArgumentError, 'No document model was provided' if document_model.blank?

      documents = document_model.all
      menus = documents.each_with_object({}) do |document, menus|
        next unless document.menus.present?

        document.menus.each_pair do |menu_id, menu_items|
          menus[menu_id] = [] if menus[menu_id].blank?

          menu_items.each do |menu_item|
            menus[menu_id].push(menu_item) unless menus[menu_id].find { |item| item.slug == menu_item.slug }
          end
        end
      end

      OpenStruct.new(menus)
    end

    def menu_for(document_model, id)
      all_menus = menus(document_model)

      all_menus[id]
    end
  end
end
