class AddNameConfirmedAtToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :name_confirmed_at, :datetime

    # 既存ユーザーには名前変更モーダルを表示しないため、確認済みとして扱う
    User.reset_column_information
    User.update_all(name_confirmed_at: Time.current)
  end

  def down
    remove_column :users, :name_confirmed_at
  end
end
