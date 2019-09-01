require "spec_helper"

describe ListsController, type: :controller do
  let(:list_not_found_message) { /Couldn't find List/ }
  let(:without_lists_message) { /Couldn't find lists !/ }
  let(:invalid_attributtes_message) { /Validation failed/ }
  let(:update_without_attributes) { /Without attributes to update!/ }
  let(:client_not_found_message) { /Client not found!/ }

  context "GET /clients/:client_id/lists" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "when has lists in db" do
        let(:page_number) { 1 }
        let(:client) { Client.last }

        before do
          FactoryBot.create_list(:list, page_number * 4, client: client)
        end

        it "should return status code 200" do
          get "/clients/#{client.id}/lists", page: page_number

          expect(response.status).to be(200)
        end

        it "should return n lists, where n is the number of registers per page" do
          get "/clients/#{client.id}/lists", page: page_number

          db_paginated_lists = List.page(page_number).per(ENV["PAGE_SIZE"])

          expect(response_as_json).not_to be_empty
          expect(response_as_json.count).not_to be(List.count)
          expect(response_as_json.count).to be(ENV["PAGE_SIZE"].to_i)
          expect(response_as_json).to eq(db_paginated_lists.as_json)
        end
      end

      context "when HAS NOT lists in db" do
        let(:client) { Client.last }

        it "should return status code 404" do
          get "/clients/#{client.id}/lists"

          expect(response.status).to be(404)
        end

        it "should return an ERROR message" do
          get "/clients/#{client.id}/lists"

          expect(response_as_json["message"]).to match(without_lists_message)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        get "/clients/#{invalid_client_id}/lists"

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        get "/clients/#{invalid_client_id}/lists"

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end

  context "GET /clients/:client_id/lists/:id" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "when list exists" do
        let(:client) { Client.last }

        before do
          FactoryBot.create(:list, client: client)
        end

        it "should return status code 200" do
          get "/clients/#{client.id}/lists/:id", id: List.last.id

          expect(response.status).to be(200)
        end

        it "should return the required list" do
          list = List.last

          get "/clients/#{client.id}/lists/:id", id: list.id

          expect(response_as_json).to eq(list.as_json)
        end
      end

      context "when list NOT exists" do
        let(:client) { Client.last }
        let(:invalid_id) { Faker::Number.between(999, 9999) }

        before do
          get "/clients/#{client.id}/lists/:id", id: invalid_id
        end

        it "should return status code 404" do
          expect(response.status).to be(404)
        end

        it "should return an ERROR message" do
          expect(response_as_json["message"]).to match(list_not_found_message)
          expect(response_as_json["message"]).to match(invalid_id.to_s)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }
      let(:invalid_list_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        get "/clients/#{invalid_client_id}/lists/:id", id: invalid_list_id

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        get "/clients/#{invalid_client_id}/lists/:id", id: invalid_list_id

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end

  context "POST /clients/:client_id/lists/" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "with valid attributes" do
        let(:client) { Client.last }
        let(:valid_attributes) {
          FactoryBot.build(:list, client_id: client.id).as_json.except("id")
        }
        let!(:initial_lists_count) { List.all.count }

        before do
          post "/clients/#{client.id}/lists", params: valid_attributes
        end

        it "should return status code 201" do
          expect(response.status).to be(201)
        end

        it "should create a new list" do
          expect(List.all.count).to be(initial_lists_count + 1)
        end

        it "should return the new list" do
          db_list = List.last

          expect(response_as_json).to eq(db_list.as_json)
        end
      end

      context "with INVALID attributes" do
        let(:client) { Client.last }
        let!(:initial_lists_count) { List.all.count }
        let(:invalid_attributes) { { name: nil } }

        before do
          post "/clients/#{client.id}/lists", params: invalid_attributes
        end

        it "should return status code 422" do
          expect(response.status).to be(422)
        end

        it "should return an ERROR message" do
          expect(response_as_json["message"]).to match(invalid_attributtes_message)
        end

        it "should NOT create a new list" do
          expect(List.all.count).to be(initial_lists_count)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        post "/clients/#{invalid_client_id}/lists"

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        post "/clients/#{invalid_client_id}/lists"

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end

  context "DELETE /clients/:client_id/lists/:id" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "when list exists" do
        let(:client) { Client.last }
        let!(:initial_lists_count) { List.all.count }

        before do
          FactoryBot.create(:list, client: client)
        end

        it "should return status code 200" do
          delete "/clients/#{client.id}/lists/:id", id: List.last.id

          expect(response.status).to be(200)
        end

        it "should delete the list" do
          list = List.last
          initial_lists_count = List.all.count

          delete "/clients/#{client.id}/lists/:id", id: list.id

          expect {
            List.find(list.id)
          }.to raise_error(ActiveRecord::RecordNotFound)

          expect(List.all.count).to be(initial_lists_count - 1)
        end
      end

      context "when list NOT exists" do
        let(:client) { Client.last }
        let(:invalid_id) { Faker::Number.between(999, 9999) }

        before do
          delete "/clients/#{client.id}/lists/:id", id: invalid_id
        end

        it "should return status code 404" do
          expect(response.status).to be(404)
        end

        it "should return an ERROR message" do
          expect(response_as_json["message"]).to match(list_not_found_message)
          expect(response_as_json["message"]).to match(invalid_id.to_s)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }
      let(:invalid_list_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        delete "/clients/#{invalid_client_id}/lists/:id", id: invalid_list_id

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        delete "/clients/#{invalid_client_id}/lists/:id", id: invalid_list_id

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end

  context "PUT /clients/:client_id/lists/:id" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "when list exists" do
        let(:client) { Client.last }

        before do
          FactoryBot.create(:list, client: client)
        end

        context "and with valid attributes" do
          let!(:list) { create(:list) }
          let(:valid_attributes) {
            FactoryBot.build(:list).as_json.except("id")
          }

          before do
            put "/clients/#{client.id}/lists/:id", id: list.id, params: valid_attributes
          end

          it "should return status code 200" do
            expect(response.status).to be(200)
          end

          it "should update the list" do
            db_list = List.find(list.id)

            expect(response_as_json).to eq(db_list.as_json)
          end
        end

        context "and WITHOUT attributes to update" do
          let(:no_attributes) { {} }
          let(:list) { List.last }

          before do
            put "/clients/#{client.id}/lists/:id", id: list.id, params: no_attributes
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
          let(:list) { List.last }

          before do
            put "/clients/#{client.id}/lists/:id", id: list.id, params: invalid_attributes
          end

          it "should return status code 422" do
            expect(response.status).to be(422)
          end

          it "should return an ERROR message" do
            expect(response_as_json["message"]).to match(invalid_attributtes_message)
          end
        end
      end

      context "when list NOT exists" do
        let(:client) { Client.last }
        let(:invalid_id) { Faker::Number.between(999, 9999) }

        before do
          put "/clients/#{client.id}/lists/:id", id: invalid_id
        end

        it "should return status code 404" do
          expect(response.status).to be(404)
        end

        it "should return an ERROR message" do
          expect(response_as_json["message"]).to match(list_not_found_message)
          expect(response_as_json["message"]).to match(invalid_id.to_s)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }
      let(:invalid_list_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        put "/clients/#{invalid_client_id}/lists/:id", id: invalid_list_id

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        put "/clients/#{invalid_client_id}/lists/:id", id: invalid_list_id

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end
end
