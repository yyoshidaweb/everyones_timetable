class AddVisibilityToEvents < ActiveRecord::Migration[8.1]
  def up
    add_column :events, :visibility, :integer, null: false, default: 0

    execute <<~SQL.squish
      UPDATE events
      SET visibility = CASE
        WHEN is_published THEN 0
        ELSE 2
      END
    SQL

    remove_column :events, :is_published
  end

  def down
    add_column :events, :is_published, :boolean, null: false, default: true

    execute <<~SQL.squish
      UPDATE events
      SET is_published = CASE
        WHEN visibility = 0 THEN TRUE
        ELSE FALSE
      END
    SQL

    remove_column :events, :visibility
  end
end
