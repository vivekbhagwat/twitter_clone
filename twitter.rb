require 'sinatra'
require 'erb'

$global_id = 1

class Message
  attr_accessor :contents, :id
  
  def initialize(str='', id=0)
    @contents = str
    @id = id
    
    $global_id += 1
  end
  
  def to_s
    contents
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
  @body = '<h3>Congratulations, you have successfully posted something that will be lost</h3>' +
    params[:message] + ' with id: ' + $global_id.to_s
  
  messages[$global_id.to_i] = Message.new(params[:message], $global_id.to_i)
  
  @body += ' and id is now' +  $global_id.to_s
    
  erb :index
end

get '/post/:id' do
  id = params[:id].to_s
  @body = "No such message exists"
  if messages[id.to_i]
    @body = "Message: " + messages[id.to_i].contents
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