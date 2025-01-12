# I18nライブラリに訳文の探索場所を指示する
I18n.load_path += Dir[Rails.root.join("lib", "locale", "*.{rb,yml}")]

# アプリケーションでの利用を許可するロケールのリストを渡す
I18n.available_locales = [ :ja, :en ]

# ロケールを:jaに変更する
I18n.default_locale = :ja
