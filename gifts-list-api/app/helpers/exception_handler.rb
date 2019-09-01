module ExceptionHandler
  include Exceptions
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, ParentCategoryNotFoundError,
                ClientNotFoundError, ProductNotFoundError, ListNotFoundError,
                CategoryNotFoundError, ProductNotInListError, ProductNotInCategoryError do |e|
      json_response({
        message: e.message,
      }, :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid, NoAttributesToUpdateError,
                ProductAlreadyInListError, ProductAlreadyInCategoryError do |e|
      json_response({
        message: e.message,
      }, :unprocessable_entity)
    end
  end
end
