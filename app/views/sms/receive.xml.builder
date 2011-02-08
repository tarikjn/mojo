xml.instruct!
xml.Response do
  @recipients.each do |recipient|
    xml.Sms({:to => recipient.cellphone}, @message)
  end
end
