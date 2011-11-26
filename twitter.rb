require 'sinatra'
require 'erb'

enable :sessions

$global_id = 1
$salt = '0!'

class User
  attr_accessor :name, :pw, :id, :posts
  
  def initialize(str='', password='', id=0)
    @name = str
    @pw = password.crypt($salt)
    @id = id
    posts = []
  end
end

class Message
  attr_accessor :contents, :id, :timestamp, :user
  
  def initialize(str='', name=nil, id=0)
    @contents = str
    @user = name
    @id = id
    @timestamp = Time.now.to_s
    
    $global_id += 1
  end
  
  def to_json
    nil.to_s
  end
  
  def to_s
    @contents + " by " + @user + ", posted at " + @timestamp
  end
end

messages = Hash.new
users = Hash.new

$ORIGINAL_LOGIN = '<a href="/login">Login</a>'
$footer = $ORIGINAL_LOGIN

get '/' do
  @body = '<form action="post" method="POST">
  Post Message Here <input type ="text" name="message" />
  <input type="submit"/>
  </form>'
  
  erb :index
end

post '/' do
  redirect('/')
end

post '/logout' do
  session = Hash.new
  $footer = $ORIGINAL_LOGIN
  redirect('/')
end

get '/login' do
  @body = '<form action="" method="POST">
  Username <input type ="text" name="username" />
  Password <input type ="password" name="password" />
  <input type="submit"/>
  </form>'
  
  erb :index
end

post '/login' do
  # @body = params[:username] + " " + params[:password] + " " + params[:password].to_s.crypt('0!')
  user = params[:username]
  
  if users[user] && users[user].pw == params[:password].crypt($salt)
    session = Hash.new
    session[user] = user
    $footer = '<a href="/logout">Logout, ' + user + '</a>'
    redirect('/')
  else
    status, headers, body = call env.merge("PATH_INFO" => 'login')
    return [status, headers, body.map(&:upcase)]
  end
end

get '/post' do
  redirect to('/post/all')
end

post '/post' do
  m = Message.new(params[:message], '', $global_id.to_i)
  messages[$global_id.to_i] = m
    
  @body = '<h3>Congratulations, you have successfully posted </h3>' +
    m.to_s + ' with id: ' + m.id.to_s
  
  @body += ' and id is now' +  $global_id.to_s
    
  erb :index
end

get '/post/all' do
  @body = '<h3>All Messages</h3>'
  messages.each do |id, m|
    @body += m.to_s + '<br/>'
  end
  
  erb :index
end

get '/posts' do
  redirect('/post/all')
end

get '/all' do
  redirect('/post/all')
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