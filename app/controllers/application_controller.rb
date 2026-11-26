class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :phone, :email, :password])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone, :email, :password, :current_password])
  end

  # User management, the equipment inventory and the activity log are admin
  # only. Run after authenticate_user!.
  def require_admin!
    return if current_user.admin?

    redirect_to root_path, alert: 'Acceso restringido a administradores'
  end

  # Admins see every company; everyone else only the ones they registered.
  def accessible_companies
    current_user.admin? ? Company.all : Company.where(user_id: current_user.id)
  end

  def accessible_requests
    Request.where(company_id: accessible_companies.select(:id))
  end
end
