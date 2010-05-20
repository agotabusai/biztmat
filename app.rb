require 'rubygems'
require 'sinatra'
require 'erb'

require 'sequel'
DB = Sequel.connect(ENV['DATABASE_URL'] || "sqlite://app.db")
Sequel::Model.strict_param_setting = false
require 'user'

require 'helpers'

require 'cnum'

enable :sessions

get "/" do
  erb :home
end

get "/users/new" do
  unless logged_in?
    @user = User.new(params[:user] || {})
    erb :"users/new"
  else
    redirect "/users/#{current_user.id}"
  end
end

post "/users" do
  begin
    @user = User.new(params[:user] || {})
    @user.save
    session[:current_user_id] = @user.id
    session[:notice] = "Sikeres regisztráció, be is vagy már jelentkezve!"
    redirect "/users/#{@user.id}"
  rescue Sequel::ValidationFailed
    session[:error] = "Hiba az űrlapban"
    erb :"users/new"
  end
end

get "/users/:id" do
  require_user
  not_found unless @user = User[params[:id]]
  erb :"users/show"
end

get "/users/:id/edit" do
  require_user
  not_found unless @user = User[params[:id]]
  if @user == current_user
    erb :"users/edit"
  else
    session[:error] = "Csak a saját adataidat szerkesztheted!"
    redirect "/users/#{@user.id}"
  end
end

put "/users/:id" do
  require_user
  not_found unless @user = User[params[:id]]
  if @user == current_user
    begin
      @user.update_except(params[:user], :login)
      session[:notice] = "Sikeres módosítás!"
      redirect "/users/#{@user.id}"
    rescue Sequel::ValidationFailed
      session[:error] = "Hiba az űrlapban"
      erb :"users/edit"
    end
  else
    session[:error] = "Csak a saját adataidat szerkesztheted!"
    redirect "/users/#{@user.id}"
  end
end

get "/users/:id/delete" do
  require_user
  not_found unless @user = User[params[:id]]
  if @user == current_user
    erb :"users/delete"
  else
    session[:error] = "Mit gondolsz, csak úgy kitörölhetsz akárkit?"
    redirect "/users/#{@user.id}"
  end
end

delete "/users/:id" do
  require_user
  not_found unless @user = User[params[:id]]
  if @user == current_user
    @user.delete
    session[:current_user_id] = nil
    session[:notice] = "Sikeresen törölted magad!"
    redirect "/"
  else
    session[:error] = "Mit gondolsz, csak úgy kitörölhetsz akárkit?"
    redirect "/users/#{@user.id}"
  end
end

post "/login" do
  if user = User.authenticate(params[:user], params[:pass])
    session[:current_user_id] = user.id
    session[:notice] = "Sikeres bejelentkezés!"
    redirect session.delete(:back_url) || "/"
  else
    session[:error] = "Hibás felhasználónév vagy jelszó"
    redirect "/"
  end
end

get "/logout" do
  session[:current_user_id] = nil
  session[:notice] = "Sikeres kijelentkezés!"
  redirect "/"
end

get "/actuarial/new" do
	if current_user.admin?
		@cnum = Cnum.new(params[:cnum] || {})
		erb :"actuarial/new"
	else
		session[:error] = "Csak az adminnak van ehhez jogosultsága!"		
		redirect "/"
	end	
end

post "/actuarial" do
	unless current_user.admin?
		session[:error] = "Csak az adminnak van ehhez jogosultsága!"		
		redirect "/"
	else
		begin
			@cnum = Cnum.new(params[:cnum] || {})
			@cnum.save
			redirect "/actuarial/new"
		rescue Sequel::ValidationFailed
      session[:error] = "Hiba az űrlapban!"
      erb :"/actuarial/new"
		end
	end
end

require 'deuterium'

get "/buy" do
	if @user = current_user
		@deuterium = Deuterium.new(params[:deuterium] || {})		
		erb :"/buy"
	else
		session[:error] = "Csak magadnak vásárolhatsz biztosítási csomagot!"
		redirect "/"
	end
end

post "/buy" do
	if @user = current_user
		@deuterium = Deuterium.new(params[:deuterium] || {})
		@deuterium[:user_id] = current_user.id
		@deuterium[:age] = current_user.age
		@cnums=Cnum.all		
		if @deuterium[:w] =~ /eleresi/
			@dx=1
			@dn=1
			@mx=1
			@cnums.each do |cnum|
				if cnum.x == @deuterium[:age]
					@dx = cnum.d
				end
				if cnum.x == @deuterium[:age] + @deuterium[:n]
					@dn = cnum.d
				end
			end
			@deuterium[:p] = (@dn.to_f/@dx*@deuterium[:s]).floor
		else
			@cnums.each do |cnum|
				if cnum.x == @deuterium[:age]
					@dx = cnum.d
					@mx = cnum.m				
				end
			end
			@deuterium[:p] = (@mx.to_f/@dx*@deuterium[:s]).floor
		end
		@deuterium.save
		session[:notice] = "Az adataidat feldolgoztuk."
		redirect "/confirm"
	end		
end

get "/confirm" do
	@deuteria = Deuterium.all
	@deuterium = @deuteria.last
	if @user = current_user
		erb :"/confirm"
	end
end

delete "/confirm" do
	@deuteria = Deuterium.all
	@deuterium = @deuteria.last
	if @user = current_user
		@deuterium.delete
		session[:notice] = "Esetleg egy másikat?"
		redirect "/buy"
	end
end

get "/users/:id/own" do
	if @user = current_user
		@deuteria = Deuterium.all
		erb :"/users/own"
	end
end
