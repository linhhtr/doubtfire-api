require 'test_helper'

  class ConvenorContactMailerTest < ActionMailer::TestCase
   #
   # Send an email from institution domain to all admin user
   #
   test 'request_project_membership' do
     user = FactoryBot.create(:user)
     unit = FactoryBot.create(:unit, group_sets: 1, student_count: 2, :groups => [ { gs: 0, students: 2} ])
     institution_email_domain = Doubtfire::Application.config.institution[:email_domain]
     doubtfire_product_name = Doubtfire::Application.config.institution[:product_name]
     user_email = "#{user.username}@#{institution_email_domain}"
     email = ConvenorContactMailer.request_project_membership(user, nil, unit, nil, nil)
     assert_emails 1 do
       email.deliver_now
     end
     assert_equal [user_email], email.from
     assert_equal User.admins.map(&:email), email.to
     assert_equal "[#{doubtfire_product_name}] Please add #{user.username} to #{unit.name}", email.subject
     assert_equal "The following user wishes to be added to #{unit.name} on " \
       "#{doubtfire_product_name}:\n\nUsername: #{user.username}\nEmail: #{user_email}\n" \
       "Name: #{user.name}", email.body.to_s
   end
 end