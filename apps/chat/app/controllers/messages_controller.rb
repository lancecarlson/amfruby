class MessagesController < ApplicationController
  def index
    puts "index!"
    @message = Message.all
  end
  
  def save
    puts "test"
    respond_to do |format|
      format.amf do
        puts params[0]
        @message = Message.new
        @message.save
      end
    end
  end
end
