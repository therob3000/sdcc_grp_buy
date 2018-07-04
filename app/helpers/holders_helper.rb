module HoldersHelper
	def send_to_holder(holder,text)
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    number = holder.user.phone
    raise "No Phone number provided for user #{holder.user.name}" if number.nil?

    number =  number.gsub(/-/, '').gsub(/\)/, '').gsub(/\(/, '').gsub(/ /, '')

    if number.length > 11
      number = "1" + number 
    end

    number = "+" + number
    # twilio API
    @client = Twilio::REST::Client.new account_sid, auth_token

    @client.api.account.messages.create(
      from: "+#{ENV['TWILIO_NUMBER']}",
      to: number,
      body: text
    )
    # persist to holder text message record
    TextMessageRecord.create(:user_id => holder.user_id)

  end
end
