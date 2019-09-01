class ProductsAssociationsController < ApplicationController
  def add_product_to_list
    client_exists_check
    product_exists_check
    list_exists_check

    @list.products << @product

    json_response({})
  end

  def remove_product_from_list
    client_exists_check
    product_exists_check
    list_exists_check

    @list.products.delete(@product)

    json_response({})
  end

  def add_product_to_category
    client_exists_check
    product_exists_check
    category_exists_check

    @category.products << @product

    json_response({})
  end

  def remove_product_from_category
    client_exists_check
    product_exists_check
    category_exists_check

    @category.products.delete(@product)

    json_response({})
  end

  private

  def client_exists_check
    begin
      Client.find(params[:client_id])
    rescue ActiveRecord::RecordNotFound
      raise ClientNotFoundError
    end
  end

  def product_exists_check
    begin
      @product = Product.where(
        client_id: params[:client_id],
      ).find(params[:product_id])
    rescue ActiveRecord::RecordNotFound
      raise ProductNotFoundError
    end
  end

  def list_exists_check
    begin
      @list = List.where(
        client_id: params[:client_id],
      ).find(params[:list_id])
    rescue ActiveRecord::RecordNotFound
      raise ListNotFoundError
    end
  end

  def category_exists_check
    begin
      @category = Category.where(
        client_id: params[:client_id],
      ).find(params[:category_id])
    rescue ActiveRecord::RecordNotFound
      raise CategoryNotFoundError
    end
  end
end
