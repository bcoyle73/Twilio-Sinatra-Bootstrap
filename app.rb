require 'sinatra'
require 'twilio-ruby'
require 'Haml'

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  if !session[:identity] then
    session[:previous_url] = request.path
    @error = 'Sorry guacamole, you need to be logged in to visit ' + request.path
    halt haml(:login_form)
  end
end

get '/' do
  haml 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/login/form' do 
  haml :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from 
end

get '/logout' do
  session.delete(:identity)
  haml "<div class='alert alert-message'>Logged out</div>"
end


get '/secure/place' do
  haml "This is a secret place that only <%=session[:identity]%> has access to!"
end