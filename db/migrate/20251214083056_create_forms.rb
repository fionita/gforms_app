class CreateForms < ActiveRecord::Migration[8.1]
  def change
    create_table :forms do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
