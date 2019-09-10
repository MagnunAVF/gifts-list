require "spec_helper"

describe ProductQueriesController, type: :controller do
  let(:client_not_found_message) { /Client not found!/ }
  let(:list_not_found_message) { /List not found!/ }
  let(:category_not_found_message) { /Category not found!/ }
  let(:invalid_page_message) { /No Products registries found for this page!/ }

  context "GET /clients/:client_id/find-products-in-list" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "when list exists" do
        before do
          FactoryBot.create(:list, client: client)
        end
        let!(:client) { Client.last }

        context "with a valid page number" do
          let!(:list) { List.last }
          let(:page) { 2 }
          let(:params) {
            {
              list_id: list.id,
              page: page,
            }
          }

          before do
            products = FactoryBot.create_list(
              :product,
              Faker::Number.between(4, 7) * ENV["PAGE_SIZE"].to_i,
              client: client,
            )
            list.products << products
          end

          it "should return status code 200" do
            get "/clients/#{client.id}/find-products-in-list", params

            expect(response.status).to be(200)
          end

          it "should return n registers, where n is the number of registers per page" do
            all_products_of_client = Product.where(client: client)

            get "/clients/#{client.id}/find-products-in-list", params

            expect(all_products_of_client.count).to_not be(response_as_json.count)
            expect(all_products_of_client.as_json).to_not eq(response_as_json)
          end
        end

        context "with a INVALID page number" do
          let!(:list) { List.last }
          let(:invalid_page) { Faker::Number.between(999, 9999) }
          let(:params) {
            {
              list_id: list.id,
              page: invalid_page,
            }
          }

          it "should return status code 404" do
            get "/clients/#{client.id}/find-products-in-list", params

            expect(response.status).to be(404)
          end

          it "should return an ERROR message" do
            get "/clients/#{client.id}/find-products-in-list", params

            expect(response_as_json["message"]).to match(invalid_page_message)
          end
        end
      end

      context "when list NOT exists" do
        let(:client) { Client.last }
        let(:invalid_list_id) { Faker::Number.between(999, 9999) }
        let(:params) {
          {
            list_id: invalid_list_id,
          }
        }

        it "should return status code 404" do
          get "/clients/#{client.id}/find-products-in-list", params

          expect(response.status).to be(404)
        end

        it "should return an ERROR message" do
          get "/clients/#{client.id}/find-products-in-list", params

          expect(response_as_json["message"]).to match(list_not_found_message)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        get "/clients/#{invalid_client_id}/find-products-in-list"

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        get "/clients/#{invalid_client_id}/find-products-in-list"

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end

  context "GET /clients/:client_id/find-products-in-category" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "when category exists" do
        before do
          FactoryBot.create(:category, client: client)
        end
        let!(:client) { Client.last }

        context "with a valid page number" do
          let!(:category) { Category.last }
          let(:page) { 2 }
          let(:params) {
            {
              category_id: category.id,
              page: page,
            }
          }

          before do
            products = FactoryBot.create_list(
              :product,
              Faker::Number.between(4, 7) * ENV["PAGE_SIZE"].to_i,
              client: client,
            )
            category.products << products
          end

          it "should return status code 200" do
            get "/clients/#{client.id}/find-products-in-category", params

            expect(response.status).to be(200)
          end

          it "should return n registers, where n is the number of registers per page" do
            all_products_of_client = Product.where(client: client)

            get "/clients/#{client.id}/find-products-in-category", params

            expect(all_products_of_client.count).to_not be(response_as_json.count)
            expect(all_products_of_client.as_json).to_not eq(response_as_json)
          end
        end

        context "with a INVALID page number" do
          let!(:category) { Category.last }
          let(:invalid_page) { Faker::Number.between(999, 9999) }
          let(:params) {
            {
              category_id: category.id,
              page: invalid_page,
            }
          }

          it "should return status code 404" do
            get "/clients/#{client.id}/find-products-in-category", params

            expect(response.status).to be(404)
          end

          it "should return an ERROR message" do
            get "/clients/#{client.id}/find-products-in-category", params

            expect(response_as_json["message"]).to match(invalid_page_message)
          end
        end
      end

      context "when category NOT exists" do
        let(:client) { Client.last }
        let(:invalid_category_id) { Faker::Number.between(999, 9999) }
        let(:params) {
          {
            category_id: invalid_category_id,
          }
        }

        it "should return status code 404" do
          get "/clients/#{client.id}/find-products-in-category", params

          expect(response.status).to be(404)
        end

        it "should return an ERROR message" do
          get "/clients/#{client.id}/find-products-in-category", params

          expect(response_as_json["message"]).to match(category_not_found_message)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        get "/clients/#{invalid_client_id}/find-products-in-category"

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        get "/clients/#{invalid_client_id}/find-products-in-category"

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end
end
