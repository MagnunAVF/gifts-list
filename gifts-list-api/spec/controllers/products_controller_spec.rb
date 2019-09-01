require "spec_helper"

describe ProductsController, type: :controller do
  let(:product_not_found_message) { /Couldn't find Product/ }
  let(:without_products_message) { /Couldn't find products !/ }
  let(:invalid_attributtes_message) { /Validation failed/ }
  let(:update_without_attributes) { /Without attributes to update!/ }
  let(:client_not_found_message) { /Client not found!/ }

  context "GET /clients/:client_id/products" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "when has products in db" do
        let(:page_number) { 1 }
        let(:client) { Client.last }

        before do
          FactoryBot.create_list(:product, page_number * 4, client: client)
        end

        it "should return status code 200" do
          get "/clients/#{client.id}/products", page: page_number

          expect(response.status).to be(200)
        end

        it "should return n products, where n is the number of registers per page" do
          get "/clients/#{client.id}/products", page: page_number

          db_paginated_products = Product.page(page_number).per(ENV["PAGE_SIZE"])

          expect(response_as_json).not_to be_empty
          expect(response_as_json.count).not_to be(Product.count)
          expect(response_as_json.count).to be(ENV["PAGE_SIZE"].to_i)
          expect(response_as_json).to eq(db_paginated_products.as_json)
        end
      end

      context "when HAS NOT products in db" do
        let(:client) { Client.last }

        it "should return status code 404" do
          get "/clients/#{client.id}/products"

          expect(response.status).to be(404)
        end

        it "should return an ERROR message" do
          get "/clients/#{client.id}/products"

          expect(response_as_json["message"]).to match(without_products_message)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        get "/clients/#{invalid_client_id}/products"

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        get "/clients/#{invalid_client_id}/products"

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end

  context "GET /clients/:client_id/products/:id" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "when product exists" do
        let(:client) { Client.last }

        before do
          FactoryBot.create(:product, client: client)
        end

        it "should return status code 200" do
          get "/clients/#{client.id}/products/:id", id: Product.last.id

          expect(response.status).to be(200)
        end

        it "should return the required product" do
          product = Product.last

          get "/clients/#{client.id}/products/:id", id: product.id

          expect(response_as_json).to eq(product.as_json)
        end
      end

      context "when product NOT exists" do
        let(:client) { Client.last }
        let(:invalid_id) { Faker::Number.between(999, 9999) }

        before do
          get "/clients/#{client.id}/products/:id", id: invalid_id
        end

        it "should return status code 404" do
          expect(response.status).to be(404)
        end

        it "should return an ERROR message" do
          expect(response_as_json["message"]).to match(product_not_found_message)
          expect(response_as_json["message"]).to match(invalid_id.to_s)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }
      let(:invalid_product_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        get "/clients/#{invalid_client_id}/products/:id", id: invalid_product_id

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        get "/clients/#{invalid_client_id}/products/:id", id: invalid_product_id

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end

  context "POST /clients/:client_id/products/" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "with valid attributes" do
        let(:client) { Client.last }
        let(:valid_attributes) {
          FactoryBot.build(:product, client_id: client.id).as_json.except("id")
        }
        let!(:initial_products_count) { Product.all.count }

        before do
          post "/clients/#{client.id}/products", params: valid_attributes
        end

        it "should return status code 201" do
          expect(response.status).to be(201)
        end

        it "should create a new product" do
          expect(Product.all.count).to be(initial_products_count + 1)
        end

        it "should return the new product" do
          db_product = Product.last

          expect(response_as_json).to eq(db_product.as_json)
        end
      end

      context "with INVALID attributes" do
        let(:client) { Client.last }
        let!(:initial_products_count) { Product.all.count }
        let(:invalid_attributes) { { name: nil } }

        before do
          post "/clients/#{client.id}/products", params: invalid_attributes
        end

        it "should return status code 422" do
          expect(response.status).to be(422)
        end

        it "should return an ERROR message" do
          expect(response_as_json["message"]).to match(invalid_attributtes_message)
        end

        it "should NOT create a new product" do
          expect(Product.all.count).to be(initial_products_count)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        post "/clients/#{invalid_client_id}/products"

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        post "/clients/#{invalid_client_id}/products"

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end

  context "DELETE /clients/:client_id/products/:id" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "when product exists" do
        let(:client) { Client.last }
        let!(:initial_products_count) { Product.all.count }

        before do
          FactoryBot.create(:product, client: client)
        end

        it "should return status code 200" do
          delete "/clients/#{client.id}/products/:id", id: Product.last.id

          expect(response.status).to be(200)
        end

        it "should delete the product" do
          product = Product.last
          initial_products_count = Product.all.count

          delete "/clients/#{client.id}/products/:id", id: product.id

          expect {
            Product.find(product.id)
          }.to raise_error(ActiveRecord::RecordNotFound)

          expect(Product.all.count).to be(initial_products_count - 1)
        end
      end

      context "when product NOT exists" do
        let(:client) { Client.last }
        let(:invalid_id) { Faker::Number.between(999, 9999) }

        before do
          delete "/clients/#{client.id}/products/:id", id: invalid_id
        end

        it "should return status code 404" do
          expect(response.status).to be(404)
        end

        it "should return an ERROR message" do
          expect(response_as_json["message"]).to match(product_not_found_message)
          expect(response_as_json["message"]).to match(invalid_id.to_s)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }
      let(:invalid_product_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        delete "/clients/#{invalid_client_id}/products/:id", id: invalid_product_id

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        delete "/clients/#{invalid_client_id}/products/:id", id: invalid_product_id

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end

  context "PUT /clients/:client_id/products/:id" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "when product exists" do
        let(:client) { Client.last }

        before do
          FactoryBot.create(:product, client: client)
        end

        context "and with valid attributes" do
          let!(:product) { create(:product) }
          let(:valid_attributes) {
            FactoryBot.build(:product).as_json.except("id")
          }

          before do
            put "/clients/#{client.id}/products/:id", id: product.id, params: valid_attributes
          end

          it "should return status code 200" do
            expect(response.status).to be(200)
          end

          it "should update the product" do
            db_product = Product.find(product.id)

            expect(response_as_json).to eq(db_product.as_json)
          end
        end

        context "and WITHOUT attributes to update" do
          let(:no_attributes) { {} }
          let(:product) { Product.last }

          before do
            put "/clients/#{client.id}/products/:id", id: product.id, params: no_attributes
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
          let(:product) { Product.last }

          before do
            put "/clients/#{client.id}/products/:id", id: product.id, params: invalid_attributes
          end

          it "should return status code 422" do
            expect(response.status).to be(422)
          end

          it "should return an ERROR message" do
            expect(response_as_json["message"]).to match(invalid_attributtes_message)
          end
        end
      end

      context "when product NOT exists" do
        let(:client) { Client.last }
        let(:invalid_id) { Faker::Number.between(999, 9999) }

        before do
          put "/clients/#{client.id}/products/:id", id: invalid_id
        end

        it "should return status code 404" do
          expect(response.status).to be(404)
        end

        it "should return an ERROR message" do
          expect(response_as_json["message"]).to match(product_not_found_message)
          expect(response_as_json["message"]).to match(invalid_id.to_s)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }
      let(:invalid_product_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        put "/clients/#{invalid_client_id}/products/:id", id: invalid_product_id

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        put "/clients/#{invalid_client_id}/products/:id", id: invalid_product_id

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end
end
