require 'sinatra'
require 'erb'

enable :sessions

$global_id = 1
$salt = '0!'

class Form
  attr_accessor :action, :method, :content, :submit
  
  def initialize(action='/',method='GET',content=[],submit={})
    @action = action
    @method = method
    @content = content
    @submit = submit
  end
  
  def to_s
    str = '<form action="' + @action + '" method="' + @method + '">'
    @content.each do |c|
      if c.is_a?Hash
        str += c[:content].to_s + '<input '
        (c.keys - [:content]).each do |input|
          str += input.to_s + '="' + c[input].to_s + '" '
        end
        str += " />\n"
      end
    end
    
    str += '<input type="submit" '
    @submit.each do |k,v|
      str += k.to_s + '="' + v.to_s + '" '
    end
    str += '/>'
    
    str + '</form>'
  end
  
  
end

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
users = {'Anonymous' => User.new('anonymous', '', 1)}
users[1] = users['Anonymous']

$current_user = 'Anonymous'
$ORIGINAL_LOGIN = '<a href="/login">Login/Register</a>'
$footer = $ORIGINAL_LOGIN

get '/' do
  # @body = '<form action="post" method="POST">
  # Post Message Here <input type ="text" name="message" />
  # <input type="submit"/>
  # </form>'
  @body = Form.new('post', 'POST', 
    [:content => "Post Message Here", 'type' => 'text', 'name' => 'message'], {}).to_s
  
  erb :index
end

post '/' do
  redirect('/')
end

post '/logout/?' do
  session = Hash.new
  $footer = $ORIGINAL_LOGIN
  $current_user = 'Anonymous'
  redirect('/')
end

get '/login/?' do
  @body = '<form action="" method="POST">
  Username <input type ="text" name="username" />
  Password <input type ="password" name="password" />
  <input type="submit"/>
  </form>'
  
  @body = Form.new('', 'POST', [
    {:content => 'Username', :type=>'text', :name=>'username'},
    {:content => 'Password', :type=>'password', :name=>'password'}], {:value=>"Login/Register"}).to_s
  
  erb :index
end

post '/login/?' do
  # @body = params[:username] + " " + params[:password] + " " + params[:password].to_s.crypt('0!')
  user = params[:username]
  pass = params[:password]

  if users[user]
    if users[user].pw == pass.crypt($salt)
      cookie = request.cookies[user]      
      response.set_cookie(user, {:value => users[user].id, :expiration => Time.now + 94608000})
      $current_user = user
      # $footer = '<a href="/logout">Logout, ' + user + '</a>'
      $footer = Form.new('/logout', 'POST', [], {:value=>"Logout, #{user}"}).to_s
      redirect('/')
    else
    
      # status, headers, body = call env.merge("PATH_INFO" => '/login')#.last.join
      # return [status, headers, body.map(&:upcase)]
    end
  else
    users[user] = User.new(user, pass, $global_id)
    users[$global_id-1] = users[user]
    
    redirect('')
  end
end

get '/post/?' do
  redirect to('/post/all')
end

post '/post/?' do
  m = Message.new(params[:message], $current_user, $global_id.to_i)
  messages[$global_id.to_i] = m
    
  @body = '<h3>Congratulations, you have successfully posted </h3>' +
    m.to_s + ' with id: ' + m.id.to_s
  
  @body += ' and id is now' +  $global_id.to_s
    
  erb :index
end

get '/post/all/?' do
  @body = '<h3>All Messages</h3>'
  messages.each do |id, m|
    @body += m.to_s + '<br/>'
  end
  
  erb :index
end

get '/posts/?' do
  redirect('/post/all')
end

get '/all/?' do
  redirect('/post/all')
end

get '/post/:id/?' do
  id = params[:id].to_s
  @body = "No such message exists"
  if messages[id.to_i]
    @body = m.to_s
    @body += "<br/>" + '<form action="" method="DELETE"><input type="submit" value="Delete"/></form>'
  end

  erb :index
end

delete '/post/:id/?' do
  id = params[:id]
  @messages[id.to_i] = nil
  @body = "Deleted."
  
  erb :index
end

get '/:user/posts' do
  user = users[:user.to_s]
  
end