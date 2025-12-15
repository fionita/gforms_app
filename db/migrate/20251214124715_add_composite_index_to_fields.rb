class AddCompositeIndexToFields < ActiveRecord::Migration[8.1]
  def change
    add_index :fields, [ :form_id, :position ], name: "index_fields_on_form_id_and_position"

    change_column_default :fields, :position, from: nil, to: 0
  end
end
