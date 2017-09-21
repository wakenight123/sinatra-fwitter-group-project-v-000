require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "password_security"
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end

  get '/' do
    erb :'/index'
  end

  get '/signup' do
    if logged_in?
      redirect "/tweets"
    else
      erb :'/signup'
    end
  end

  post '/signup' do
    if (!params["username"].empty?) && (!params["email"].empty?) && (!params["password"].empty?)
      @user = User.create(:username=>params[:username], :email=>params[:email], :password=>params[:password])
      @user.save
      session[:user_id] = @user.id
      redirect "/tweets"
    else
      redirect "/signup"
    end
  end

  get '/users/:slug' do
    @user=User.find_by_slug(params[:slug])
    #if (session[:user_id] = @user.id)
      erb :'/users/show'
    #end
  end

  get '/tweets' do
    if logged_in?
      #@user = User.find(session[:user_id])
      erb :'/tweets/index'

    else
      redirect "/login"
    end
  end

  get '/tweets/new' do
    if logged_in?
      @user = User.find(session[:user_id])
      erb :'/tweets/new'
    else
      redirect '/login'
    end
  end

  get '/tweets/:id' do
    if logged_in?
      @tweet=Tweet.find(params[:id])
      erb :'/tweets/show'
    else
      redirect "/login"
    end
  end

  post '/tweets' do
    if !params[:content].empty?
      @user = User.find(session[:user_id])
      @tweet = Tweet.create(content: params[:content])
      @user.tweets << @tweet
      #binding.pry
      redirect "/tweets/#{@tweet.id}"
    else
      redirect "/tweets/new"
    end
  end

  get '/tweets/:id/edit' do
    if logged_in?
      @user = User.find(session[:user_id])
      @tweet= Tweet.find_by(id: params[:id])
      erb :'/tweets/edit'
    else
      redirect '/login'
    end
  end

  patch '/tweets/:id' do
    @tweet= Tweet.find_by(id: params[:id])
    if params["content"].empty?
      redirect "/tweets/#{@tweet.id}/edit"
    else
      @tweet.update(content: params["content"])
      redirect "/tweets/#{@tweet.id}"
    end
  end

  delete '/tweets/:id/delete' do
    @tweet= Tweet.find_by(id: params[:id])
    if logged_in? && (@tweet.user_id = session[:user_id])
      @tweet.delete
      redirect '/tweets'
    end
  end

  get '/login' do
    if logged_in?
      redirect "/tweets"
    else
      erb :'/login'
    end
  end

  post '/login' do
    @user=User.find_by(:username=>params[:username])
    if @user.authenticate(params[:password])
      session[:user_id]=@user.id
      redirect "/tweets"
    else
      redirect "/login"
    end
  end

  get '/logout' do
    session.clear
    redirect "/login"
  end

end
