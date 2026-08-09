class FeedbackMailer < ApplicationMailer
  def submitted(feedback)
    @feedback = feedback
    mail(
      to: feedback_notify_to,
      subject: "【みんなのタイムテーブル】ご意見箱に投稿がありました"
    )
  end

  private

  def feedback_notify_to
    address = Rails.application.credentials.dig(:feedback, :notify_to)
    return address if address.present?
    return "developer@example.com" if Rails.env.local?

    raise "credentials.feedback.notify_to が未設定です"
  end
end
