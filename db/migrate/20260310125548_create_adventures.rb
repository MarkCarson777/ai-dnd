class CreateAdventures < ActiveRecord::Migration[8.1]
  def change
    create_table :adventures do |t|
      t.string :character_name
      t.string :character_class
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
