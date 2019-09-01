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
    id = params[:client_id]

    client = Client.find(id)

    json_response(client)
  end

  def create
    client = Client.create!(client_params)

    json_response(client, :created)
  end

  def delete
    id = params[:client_id]

    client = Client.find(id)
    client.delete

    json_response({})
  end

  def update
    id = params[:client_id]

    if params.except("client_id") == {}
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
