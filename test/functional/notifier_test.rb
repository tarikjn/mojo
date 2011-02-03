require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  test "new_entrant" do
    mail = Notifier.new_entrant
    assert_equal "New entrant", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
