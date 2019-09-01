require "spec_helper"

describe ClientsController, type: :controller do
  let(:client_not_found_message) { /Couldn't find Client/ }
  let(:without_clients_message) { /Couldn't find Clients !/ }
  let(:invalid_attributtes_message) { /Validation failed/ }
  let(:update_without_attributes) { /Without attributes to update!/ }

  context "GET /clients" do
    context "when has clients in db" do
      let(:page_number) { 2 }

      before do
        FactoryBot.create_list(:client, page_number * 3)
      end

      it "should return status code 200" do
        get "/clients", page: page_number

        expect(response.status).to be(200)
      end

      it "should return n clients, where n is the number of registers per page" do
        get "/clients", page: page_number

        db_paginated_clients = Client.page(page_number).per(ENV["PAGE_SIZE"])

        expect(response_as_json).not_to be_empty
        expect(response_as_json.count).not_to be(Client.count)
        expect(response_as_json.count).to be(ENV["PAGE_SIZE"].to_i)
        expect(response_as_json).to eq(db_paginated_clients.as_json)
      end
    end

    context "when HAS NOT clients in db" do
      before do
        get "/clients"
      end

      it "should return status code 404" do
        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        expect(response_as_json["message"]).to match(without_clients_message)
      end
    end
  end

  context "GET /clients/:id" do
    before do
      FactoryBot.create(:client)
    end

    context "when client exists" do
      it "should return status code 200" do
        get "/clients/:id", id: Client.last.id

        expect(response.status).to be(200)
      end

      it "should return the required client" do
        client = Client.last

        get "/clients/:id", id: client.id

        expect(response_as_json).to eq(client.as_json)
      end
    end

    context "when client NOT exists" do
      let(:invalid_id) { Faker::Number.between(999, 9999) }

      before do
        get "/clients/:id", id: invalid_id
      end

      it "should return status code 404" do
        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        expect(response_as_json["message"]).to match(client_not_found_message)
        expect(response_as_json["message"]).to match(invalid_id.to_s)
      end
    end
  end

  context "POST /clients" do
    context "with valid attributes" do
      let(:valid_attributes) {
        FactoryBot.build(:client).as_json.except("id")
      }
      let!(:initial_clients_count) { Client.all.count }

      before do
        post "/clients", params: valid_attributes
      end

      it "should return status code 201" do
        expect(response.status).to be(201)
      end

      it "should create a new client" do
        expect(Client.all.count).to be(initial_clients_count + 1)
      end

      it "should return the new client" do
        db_client = Client.last

        expect(response_as_json).to eq(db_client.as_json)
      end
    end

    context "with INVALID attributes" do
      let!(:initial_clients_count) { Client.all.count }
      let(:invalid_attributes) { { name: nil } }

      before do
        post "/clients", params: invalid_attributes
      end

      it "should return status code 422" do
        expect(response.status).to be(422)
      end

      it "should return an ERROR message" do
        expect(response_as_json["message"]).to match(invalid_attributtes_message)
      end

      it "should NOT create a new client" do
        expect(Client.all.count).to be(initial_clients_count)
      end
    end
  end

  context "DELETE /clients/:id" do
    before do
      FactoryBot.create_list(:client, 3)
    end

    context "when client exists" do
      let!(:initial_clients_count) { Client.all.count }

      it "should return status code 200" do
        delete "/clients/:id", id: Client.last.id

        expect(response.status).to be(200)
      end

      it "should delete the client" do
        client = Client.last

        delete "/clients/:id", id: client.id

        expect {
          Client.find(client.id)
        }.to raise_error(ActiveRecord::RecordNotFound)

        expect(Client.all.count).to be(initial_clients_count - 1)
      end
    end

    context "when client NOT exists" do
      let(:invalid_id) { Faker::Number.between(999, 9999) }

      before do
        delete "/clients/:id", id: invalid_id
      end

      it "should return status code 404" do
        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        expect(response_as_json["message"]).to match(client_not_found_message)
        expect(response_as_json["message"]).to match(invalid_id.to_s)
      end
    end
  end

  context "PUT /clients/:id" do
    before do
      FactoryBot.create(:client)
    end

    context "when client exists" do
      context "and with valid attributes" do
        let!(:client) { create(:client) }
        let(:valid_attributes) {
          FactoryBot.build(:client).as_json.except("id")
        }

        before do
          put "/clients/:id", id: client.id, params: valid_attributes
        end

        it "should return status code 200" do
          expect(response.status).to be(200)
        end

        it "should update the client" do
          db_client = Client.find(client.id)

          expect(response_as_json).to eq(db_client.as_json)
        end
      end

      context "and WITHOUT attributes to update" do
        let(:no_attributes) { {} }
        let(:client) { Client.last }

        before do
          put "/clients/:id", id: client.id, params: no_attributes
        end

        it "should return status code 422" do
          expect(response.status).to be(422)
        end

        it "should return an ERROR message" do
          expect(response_as_json["message"]).to match(update_without_attributes)
        end
      end

      context "and with INVALID attributes" do
        let(:invalid_attributes) { { name: nil } }
        let(:client) { Client.last }

        before do
          put "/clients/:id", id: client.id, params: invalid_attributes
        end

        it "should return status code 422" do
          expect(response.status).to be(422)
        end

        it "should return an ERROR message" do
          expect(response_as_json["message"]).to match(invalid_attributtes_message)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_id) { Faker::Number.between(999, 9999) }
      let(:valid_attributes) {
        FactoryBot.build(:client).as_json.except("id")
      }

      before do
        put "/clients/:id", id: invalid_id, params: valid_attributes
      end

      it "should return status code 404" do
        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        expect(response_as_json["message"]).to match(client_not_found_message)
        expect(response_as_json["message"]).to match(invalid_id.to_s)
      end
    end
  end
end
