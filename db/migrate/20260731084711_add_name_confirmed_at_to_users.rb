class AddNameConfirmedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    # 既存ユーザーにも名前変更モーダルを表示するため、初期値は未設定のままにする
    add_column :users, :name_confirmed_at, :datetime
  end
end
