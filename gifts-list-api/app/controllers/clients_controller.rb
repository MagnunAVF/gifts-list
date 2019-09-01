class ClientsController < ApplicationController
  def index
    if params[:page]
      page = params[:page]
    else
      page = 1
    end

    clients = Client.page(page).per(ENV["PAGE_SIZE"])

    if clients.count == 0
      raise ActiveRecord::RecordNotFound, "Couldn't find Clients !"
    end

    json_response(clients)
  end

  def show
    id = params[:id]

    client = Client.find(id)

    json_response(client)
  end

  def create
    name = params[:name]

    client = Client.create!(client_params)

    json_response(client, :created)
  end

  def delete
    id = params[:id]

    client = Client.find(id)
    client.delete

    json_response({})
  end

  def update
    id = params[:id]

    if params.except("id") == {}
      raise NoAttributesToUpdateError
    end

    client = Client.find(id)
    client.update!(client_params)

    json_response(client)
  end

  private

  def client_params
    params.permit(:name)
  end
end
