module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    rescue_from ActionController::ParameterMissing, with: :bad_request

    # Catch any other errors in production
    rescue_from StandardError, with: :internal_server_error if Rails.env.production?
  end

  private

  def not_found(exception)
    log_error(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def unprocessable_entity(exception)
    log_error(exception)
    render json: { error: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def bad_request(exception)
    log_error(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def internal_server_error(exception)
    log_error(exception)
    render json: { error: "Internal server error" }, status: :internal_server_error
  end

  def log_error(exception)
    Rails.logger.error "#{exception.class}: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n") if Rails.env.development?
  end
end
