class Mailer < ActionMailer::Base
  default from: 'luis@zamith.pt',
          to: 'luis@zamith.pt'

  def error_creating_dist
    mail(subject: '[Broker]: Failed to create dist')
  end
end
