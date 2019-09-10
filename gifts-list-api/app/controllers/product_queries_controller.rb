class ProductQueriesController < ApplicationController
  def find_products_in_list
    if params[:page]
      page = params[:page]
    else
      page = 1
    end

    client_exists_check
    list_exists_check

    @products = @list.products.page(page).per(ENV["PAGE_SIZE"])

    if @products.count == 0
      raise PaginatedProductsNotFound
    end

    json_response(@products)
  end

  def find_products_in_category
    if params[:page]
      page = params[:page]
    else
      page = 1
    end

    client_exists_check
    category_exists_check

    @products = @category.products.page(page).per(ENV["PAGE_SIZE"])

    if @products.count == 0
      raise PaginatedProductsNotFound
    end

    json_response(@products)
  end

  private

  def client_exists_check
    begin
      Client.find(params[:client_id])
    rescue ActiveRecord::RecordNotFound
      raise ClientNotFoundError
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
