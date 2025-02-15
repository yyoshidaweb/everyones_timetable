class CreateArtists < ActiveRecord::Migration[8.0]
  def change
    create_table :artists do |t|
      t.references :stage, null: false, foreign_key: true
      t.string :name
      t.time :start_time
      t.time :end_time
      t.string :notes

      t.timestamps
    end
  end
end
