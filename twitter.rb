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
end

messages = Hash.new

get /\// do
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
    params[:message]
  
  messages[@global_id] = Message.new(params[:message], @global_id)
    
  erb :index
end

get '/post/:id' do
  @body = @messages[:id.to_i]
  
  erb :index
end

delete '/post/:id' do
  @messages[:id.to_i] = nil
  @body = "Deleted."
  
  erb :index
end