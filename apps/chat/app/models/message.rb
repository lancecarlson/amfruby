# == Schema Information
# Schema version: 20090419204912
#
# Table name: messages
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  message    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Message < ActiveRecord::Base
end
