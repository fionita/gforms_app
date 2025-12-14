class CreateFields < ActiveRecord::Migration[8.1]
  def change
    create_table :fields do |t|
      t.references :form, null: false, foreign_key: true
      t.string :field_type
      t.string :label
      t.json :options
      t.integer :position

      t.timestamps
    end
  end
end
