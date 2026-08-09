class ApplicationMailer < ActionMailer::Base
  default from: -> { mailer_from }
  layout "mailer"

  private

  def mailer_from
    Rails.application.credentials.dig(:mailer, :from).presence ||
      "みんなのタイムテーブル <noreply@minnanotimetable.com>"
  end
end
