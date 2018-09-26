class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_admin!
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
   dash_path
  end

  force_ssl :if => Proc.new{ force_ssl? }

  def api_query(variables = {})
    query_name = "#{controller_name}_#{action_name}".upcase
    Cuttlefish::ApiClient.query(
      Cuttlefish::ApiClient.const_get(query_name),
      # Convert variable names to camelcase for graphql
      variables: Hash[variables.map{ |k, v| [k.to_s.camelize(:lower), v]}],
      current_admin: current_admin
    )
  end

  # Take graphql object with errors and attach them to the given form object
  def copy_graphql_errors(graphql, form)
    graphql.errors.each do |error|
      if error.path[0] == 'attributes'
        form.errors.add(
          error.path[1].underscore,
          error.type.downcase.to_sym,
          message: error.message
        )
      end
    end
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  # Don't use SSL for the TrackingController and in development
  def force_ssl?
   controller_name != "tracking" && !Rails.env.development? && !Rails.configuration.disable_ssl
  end

  def pundit_user
    current_admin
  end
end
