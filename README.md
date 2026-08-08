# 🎶 みんなのタイムテーブル（β）
音楽フェス向けタイムテーブル作成サービス

文字だけでタイムテーブルができる。スマホでもPCでも、誰でも使える。

## サービスURL
https://minnanotimetable.com

## トップページのスクリーンショット

<img width="300" alt="スマートフォンでトップページを表示した際のスクリーンショット" src="https://github.com/user-attachments/assets/1f7d060c-872c-4df3-9f48-ea29442c310d" />



## デモ動画

<img width="300" alt="スマートフォンでタイムテーブルに出演情報を追加している場面のGIF画像" src="https://github.com/user-attachments/assets/a2d0d626-1d3f-40fd-98d0-a65799763be6" />


🎥 [フルのデモ動画を見る（約38秒）→](https://github.com/user-attachments/assets/9aee078f-4536-40a7-8e22-44cd3f3c29d4)



---

## サービス概要

「みんなのタイムテーブル」は、
音楽フェスのWeb版タイムテーブルを簡単に作れるサービスです。

これまで、タイムテーブルが画像形式しかない場合、スマホでは拡大しないと読めないという課題がありました。

本サービスはこの問題を解決することを目指しています。



## 想定ユーザー

* イベント参加者
* 音楽フェス主催者
* ライブイベント運営者

将来的には、音楽フェス主催者の公式タイムテーブル作成ツールとしても利用されることを目標にしています。



## 主な機能

* 文字を入力するだけでタイムテーブルが出来上がる
* QRコードでタイムテーブルを共有
* Googleアカウントログイン
* レスポンシブ対応



## 技術スタック

### フロントエンド
* Hotwire
* Tailwind CSS

### バックエンド
* Ruby
* Ruby on Rails

### DB
* SQLite（開発・ステージング環境で利用）
* PostgreSQL（本番環境で、Render Postgresを利用）

### 認証
* Google OAuth

### ホスティング
* Render
    * ステージング環境：無料のFree instance
    * 本番環境：有料のStarter instance

### 運用監視
* Sentry（エラー監視・パフォーマンストレース）
* UptimeRobot（死活監視）

### 単体テスト
* Minitest（ほとんど全てのコントローラーに対して作成）

### 依存関係管理
依存関係は [Dependabot](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/secure-your-dependencies/configuring-dependabot-security-updates) によって週1回アップデートしており、セキュリティ・安定性を保っています。



## ローカル開発環境構築手順

### 必要環境

* Ruby
* Bundler
* Node.js
* mise

### セットアップ手順

```
# リポジトリをクローン
git clone https://github.com/yyoshidaweb/minnanotimetable.git

# クローンしたディレクトリに移動
cd minnanotimetable

# miseの設定を信頼
mise trust

# 指定バージョンのランタイムをインストール
mise install

# gem インストール
bundle install

# DBセットアップ
bin/rails db:prepare

# サーバー起動（開発モード）
bin/dev
```

[http://localhost:3000](http://localhost:3000) で起動します。

※Googleログインは環境ごとにクライアントIDとクライアントシークレットを発行する必要があるため、次の手順を実行後に利用可能になります。

### Googleログインを利用するための設定

[Google認証機能作成手順 · yyoshidaweb/minnanotimetable Wiki](https://github.com/yyoshidaweb/minnanotimetable/wiki/Google%E8%AA%8D%E8%A8%BC%E6%A9%9F%E8%83%BD%E4%BD%9C%E6%88%90%E6%89%8B%E9%A0%86) を参考にして、Googleログインに必要なクライアントIDとクライアントシークレットを正しく設定すると、Googleログインが利用可能になります。

### 複数の作業を並行して進める場合

複数の作業を同時に進めたい場合は、`git worktree` で作業ディレクトリを分けます。同じディレクトリでブランチを切り替えると、進行中の作業や起動中の開発サーバーに影響してしまうためです。

`bin/worktree` がworktreeの作成とセットアップをまとめて行います。

```bash
# origin/mainを基点にブランチを作り、worktreeを作成してセットアップする
bin/worktree add feat/460-example

# 作成したworktreeに移動
cd .worktrees/feat-460-example

# ポートを変えれば、既存の開発サーバーと同時に起動できる
PORT=3001 bin/dev
```

worktreeは `.worktrees/` 配下に作成されます。gitignoreされている `config/master.key` と `config/credentials/*.key` は自動でコピーされ、データベースはworktreeごとに別ファイルになるため、テストを並行実行しても衝突しません。

作業が終わったら、メインの作業ディレクトリで削除します。

```bash
# worktreeの一覧を確認
bin/worktree list

# worktreeを削除（未コミットの変更がある場合は中断される）
bin/worktree remove feat/460-example
```

ブランチ自体は残るため、不要であれば `git branch -d feat/460-example` で別途削除してください。





## テスト実行

```bash
bin/rails test
```




## デプロイフロー

1. プルリクエスト作成時にRenderが [Pull Request Previews](https://render.com/docs/service-previews) 機能によってプレビュー環境を作成

2. プルリクエストを`main`ブランチにマージするとRenderが自動デプロイ
    - 同時にステージング環境にも同じ内容が自動デプロイされます



## 運用監視

いずれも無料枠の範囲で、本番環境のみを対象にしています。PRプレビューやステージングには送信・監視しません。

### Sentry（エラー監視）

例外と低サンプル率のパフォーマンストレースを収集します。

1. [Sentry](https://sentry.io/) で Ruby / Rails プロジェクトを作成し、DSNを発行する
2. Renderの本番サービスに環境変数 `SENTRY_DSN` を設定する（ステージング・プレビューには設定しない）
3. デプロイ後、本番で意図的な例外や `Sentry.capture_message("test")` でイベントが届くことを確認する
4. Sentry側でアラート通知（メール等）を設定する

アプリ側は `config/initializers/sentry.rb` で初期化しています。`RAILS_ENV=production` かつ `SENTRY_DSN` があり、`IS_PULL_REQUEST` が `true` でない場合のみ有効です。トレーシングのサンプル率は無料枠を意識して `0.05` です。

### UptimeRobot（死活監視）

Rails標準のヘルスチェック `GET /up` を監視します。

1. [UptimeRobot](https://uptimerobot.com/) でアカウントを作成する
2. HTTP(s)モニターを追加する
   - URL: `https://minnanotimetable.com/up`
   - 監視間隔: 5分（無料枠）
   - 期待するステータス: HTTP 200
3. アラート連絡先（メール等）を設定する
4. モニターがUpになることを確認する



## 今後の予定

* マイタイムテーブル作成機能を実装
* ページタイトルを動的に変化させる
* ページごとに適切なOGP画像を設定する
* etc...

リアルタイムの開発状況は [カンバン](https://github.com/users/yyoshidaweb/projects/2) でも確認できます。




## 制作背景

以前、音楽フェス「下北沢にて'24」に参加した際、あるバンドのMC中に「出演者が多すぎてタイムテーブルがとても細かくなっている」という話を聞きました。

このとき、「音楽フェスのWeb版タイムテーブルを簡単に作れるサービスを作ろう！」と思ったことがきっかけで、みんなのタイムテーブルのアイデアが生まれました。



## 関連記事
### サービスへの想い
- [音楽フェスのWeb版タイムテーブルを簡単に作れるサービスをリリースしました🎉](https://note.com/yyoshidaweb/n/n376bca4c9b06)（note）

### 技術構成と開発裏話
- [みんなのタイムテーブルβ版リリース🎉 技術選定理由と表の描画速度改善の裏話](https://zenn.dev/yyoshidaweb/articles/299b6dbb16a067)（Zenn）

---


## 💡 さらに詳しい内容をまとめたWikiもあります
[Home · yyoshidaweb/minnanotimetable Wiki](https://github.com/yyoshidaweb/minnanotimetable/wiki) に要件定義書やシーケンス図、ER図、開発中に詰まったポイントのTipsなどをまとめています。



### Wiki形式でドキュメント整備をしている理由
このGitHub Wikiを作っている理由は、将来的にもしも自分が「みんなのタイムテーブル」の開発から離脱することになったとしても、ずっとこのサービスを続けたいからです。

そのため、GitHub Wikiとしてオープンなドキュメントを整備することで、スムーズに協力者を募ることや、企業に譲渡することができる状態を維持したいと考えています。

興味のある方は、ぜひご覧ください。



## フィードバックを募集しています

現在β版のため、仕様変更やUI改善を随時行っています。\
ご意見・ご要望など、 [みんなのタイムテーブル お問い合わせフォーム](https://docs.google.com/forms/d/e/1FAIpQLSfJBlhMJb4MWDX_xWlc2lel1P_X5zGTmySXlcWU7De_XtSJmw/viewform) からフィードバックをいただけると嬉しいです。


## ライセンス

本リポジトリのコードの著作権は作者に帰属します。\
許可なく複製・改変・再配布・商用利用することを禁止します。
