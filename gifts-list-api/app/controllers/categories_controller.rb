class CategoriesController < ApplicationController
  def index
    if params[:page]
      page = params[:page]
    else
      page = 1
    end

    client_exists_check

    categories = Category.where(client_id: params[:client_id]).page(page).per(ENV["PAGE_SIZE"])

    if categories.count == 0
      raise ActiveRecord::RecordNotFound, "Couldn't find categories !"
    end

    json_response(categories)
  end

  def show
    client_exists_check

    id = params[:id]

    category = Category.find(id)

    json_response(category)
  end

  def create
    client_exists_check

    category = Category.create!(category_params)

    json_response(category, :created)
  end

  def delete
    client_exists_check

    id = params[:id]

    category = Category.find(id)
    category.delete

    json_response({})
  end

  def update
    client_exists_check

    id = params[:id]
    client_id = params[:client_id]

    category = Category.find(id)

    if params.except("id", "client_id") == {}
      raise NoAttributesToUpdateError
    end

    category.update!(category_params)

    json_response(category)
  end

  private

  def category_params
    params.permit(:name, :client_id)
  end

  def client_exists_check
    begin
      client = Client.find(params[:client_id])
    rescue ActiveRecord::RecordNotFound
      raise ClientNotFoundError
    end
  end
end
