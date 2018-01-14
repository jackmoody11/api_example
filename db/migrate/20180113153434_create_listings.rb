class CreateListings < ActiveRecord::Migration[5.1]
  def change
    create_table :listings do |t|
      t.integer :isbn
      t.string :title
      t.string :author
      t.decimal :price

      t.timestamps
    end
  end
end
