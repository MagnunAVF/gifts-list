class ProductsController < ApplicationController
  def index
    if params[:page]
      page = params[:page]
    else
      page = 1
    end

    client_exists_check

    products = Product.where(client_id: params[:client_id]).page(page).per(ENV["PAGE_SIZE"])

    if products.count == 0
      raise ActiveRecord::RecordNotFound, "Couldn't find products !"
    end

    json_response(products)
  end

  def show
    client_exists_check

    id = params[:id]

    product = Product.find(id)

    json_response(product)
  end

  def create
    client_exists_check

    product = Product.create!(product_params)

    json_response(product, :created)
  end

  def delete
    client_exists_check

    id = params[:id]

    product = Product.find(id)
    product.delete

    json_response({})
  end

  def update
    client_exists_check

    id = params[:id]
    client_id = params[:client_id]

    product = Product.find(id)

    if params.except("id", "client_id") == {}
      raise NoAttributesToUpdateError
    end

    product.update!(product_params)

    json_response(product)
  end

  private

  def product_params
    params.permit(:name, :price, :client_id)
  end

  def client_exists_check
    begin
      client = Client.find(params[:client_id])
    rescue ActiveRecord::RecordNotFound
      raise ClientNotFoundError
    end
  end
end
