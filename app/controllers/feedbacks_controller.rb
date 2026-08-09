class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.user = current_user if user_signed_in?

    if @feedback.save
      send_notification_email(@feedback)
      redirect_to root_path, notice: "ご意見を送信しました。ありがとうございます。"
    else
      redirect_to root_path, alert: @feedback.errors.full_messages.to_sentence.presence || "ご意見を送信できませんでした。"
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:body)
  end

  def send_notification_email(feedback)
    return if preview_environment?

    FeedbackMailer.submitted(feedback).deliver_now
  end
end
