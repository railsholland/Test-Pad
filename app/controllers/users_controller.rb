class UsersController < ApplicationController

	before_filter	:authenticate, 		:only => [:index, :edit, :update, :destroy]
	before_filter	:correct_user,			:only => [:edit, :update]
	before_filter	:admin_user,			:only => :destroy
	before_filter	:not_signed_in_user,	:only => [:new, :create] #100% Holland code, and it works!
	
	def index
		@title = "All users"
		@users = User.paginate(:page => params[:page])
	end	
	
	def show
		@user 		=	User.find(params[:id])
		@title 		=	@user.name 
	end  	
  	
  	def new
  		@user = User.new
		@title="Sign up" 
  	end
  	
  	def create
  		@user = User.new(params[:user])
  		if @user.save
  			sign_in @user
  			flash[:success] = "Welcome to the Sample App!"
  			redirect_to @user
		else
			@title = "Sign up"
			@user.password = nil #not sure which is better - nil or empty string, both work
			@user.password_confirmation = nil
			render 'new'
		end
	end
	
	def destroy
		#add code here to make sure admin can't destroy himself, pg. 409
		if User.find(params[:id]) == current_user
			flash[:error] = "Admin user cannot delete self."
			redirect_to users_path
		else		
			User.find(params[:id]).destroy
			flash[:success] = "User destroyed."
			redirect_to users_path
		end
	end
	
	def edit
		@title	= "Edit user"
	end
	
	def update
		@user = User.find(params[:id])    #<-- should be able to get rid of this with our new before-filter
		if @user.update_attributes(params[:user])
			flash[:success] = "Profile updated."
			redirect_to @user
		else
			@title = "Edit user"
			render 'edit'
		end
	end
	
	private
		
		def authenticate
			deny_access unless signed_in?
		end
		
		def correct_user
			@user = User.find(params[:id])
			redirect_to(root_path) unless current_user?(@user)
		end
		
		def admin_user
			redirect_to(root_path) unless current_user.admin?
		end
		
		def not_signed_in_user
			redirect_to(root_path) unless !signed_in?	
		end
end
