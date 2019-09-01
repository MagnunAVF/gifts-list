module ExceptionHandler
  include Exceptions
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({
        message: e.message,
      }, :not_found)
    end

    rescue_from ParentCategoryNotFoundError do |e|
      json_response({
        message: e.message,
      }, :not_found)
    end

    rescue_from ClientNotFoundError do |e|
      json_response({
        message: e.message,
      }, :not_found)
    end

    rescue_from ProductNotFoundError do |e|
      json_response({
        message: e.message,
      }, :not_found)
    end

    rescue_from ListNotFoundError do |e|
      json_response({
        message: e.message,
      }, :not_found)
    end

    rescue_from CategoryNotFoundError do |e|
      json_response({
        message: e.message,
      }, :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      json_response({
        message: e.message,
      }, :unprocessable_entity)
    end

    rescue_from NoAttributesToUpdateError do |e|
      json_response({
        message: e.message,
      }, :unprocessable_entity)
    end
  end
end
