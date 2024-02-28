class CreateLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :links do |t|
      t.string :short_url
      t.text :long_url
      t.string :custom_url
      t.integer :clicks

      t.timestamps
    end
  end
end
