require 'celluloid'

class ChatServer
  include Celluloid
  attr_reader :history
  
  def self.start
    supervise_as :chat_server
  end
  
  def self.actor
    Celluloid::Actor[:chat_server]
  end
    
  def initialize
    @users = {}
    @history = History.new
  end
  
  def register(name, client)
    @users[name] = client
    event :join, name
  end
  
  def unregister(name)
    @users.delete name
    event :part, name
  end
  
  def send_message(user, str)
    event :message, user, str
  end
    
  def users
    @users.map { |name, _| {:name => name} }
  end
    
  def event(type, user, content = nil)
    ev = {
      :event => type,
      :time  => Time.now.xmlschema,
      :user  => user
    }
    ev[:content] = content if content
    
    @history << ev
    publish ev
  end
  
  def publish(message)    
    @users.each do |_, user|
      user.send_message message
    end
  end
end