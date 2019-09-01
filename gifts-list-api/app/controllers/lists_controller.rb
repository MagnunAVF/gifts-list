class ListsController < ApplicationController
  def index
    if params[:page]
      page = params[:page]
    else
      page = 1
    end

    client_exists_check

    lists = List.where(client_id: params[:client_id]).page(page).per(ENV["PAGE_SIZE"])

    if lists.count == 0
      raise ActiveRecord::RecordNotFound, "Couldn't find lists !"
    end

    json_response(lists)
  end

  def show
    client_exists_check

    id = params[:id]

    list = List.find(id)

    json_response(list)
  end

  def create
    client_exists_check

    list = List.create!(list_params)

    json_response(list, :created)
  end

  def delete
    client_exists_check

    id = params[:id]

    list = List.find(id)
    list.delete

    json_response({})
  end

  def update
    client_exists_check

    id = params[:id]
    client_id = params[:client_id]

    list = List.find(id)

    if params.except("id", "client_id") == {}
      raise NoAttributesToUpdateError
    end

    list.update!(list_params)

    json_response(list)
  end

  private

  def list_params
    params.permit(:name, :price, :client_id)
  end

  def client_exists_check
    begin
      Client.find(params[:client_id])
    rescue ActiveRecord::RecordNotFound
      raise ClientNotFoundError
    end
  end
end
