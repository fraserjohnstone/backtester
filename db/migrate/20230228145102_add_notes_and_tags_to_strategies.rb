class AddNotesAndTagsToStrategies < ActiveRecord::Migration[7.0]
  def change
    add_column :strategies, :notes, :text
    add_column :strategies, :tags, :json
  end
end
