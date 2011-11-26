require 'sinatra'
require 'erb'

$global_id = 1

class Message
  attr_accessor :contents, :id, :timestamp
  
  def initialize(str='', id=0)
    @contents = str
    @id = id
    @timestamp = Time.now.to_s
    
    $global_id += 1
  end
  
  def to_s
    "Message: " + @contents + " at " + @timestamp
  end
end

messages = Hash.new

get '/' do
  @body = '<form action="post" method="POST">
  Post Message Here <input type ="text" name="message" />
  <input type="submit"/>
  </form>'
  
  erb :index
end

get '/post' do
  redirect to('/post/all')
end

post '/post' do
  m = Message.new(params[:message], $global_id.to_i)
  messages[$global_id.to_i] = m
    
  @body = '<h3>Congratulations, you have successfully posted </h3>' +
    m.to_s + ' with id: ' + m.id.to_s
  
  @body += ' and id is now' +  $global_id.to_s
    
  erb :index
end

get '/post/all' do
  @body = '<h3>All Messages</h3>'
  messages.each do |m|
    @body += m.to_s
  end
  
  erb :index
end

get '/post/:id' do
  id = params[:id].to_s
  @body = "No such message exists"
  if messages[id.to_i]
    @body = m.to_s
    @body += "<br/>" + '<form action="" method="DELETE"><input type="submit" value="Delete"/></form>'
  end

  erb :index
end

delete '/post/:id' do
  id = params[:id]
  @messages[id.to_i] = nil
  @body = "Deleted."
  
  erb :index
end