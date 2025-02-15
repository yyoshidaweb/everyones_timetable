class CreateStages < ActiveRecord::Migration[8.0]
  def change
    create_table :stages do |t|
      t.references :timetable, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
