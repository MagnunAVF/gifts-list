require "spec_helper"

describe ProductsAssociationsController, type: :controller do
  let(:client_not_found_message) { /Client not found!/ }
  let(:product_not_found_message) { /Product not found!/ }
  let(:list_not_found_message) { /List not found!/ }
  let(:category_not_found_message) { /Category not found!/ }
  let(:product_not_in_list_message) { /Product not in List!/ }
  let(:product_already_in_list_message) { /Product already in List!/ }
  let(:product_not_in_category_message) { /Product not in Category!/ }
  let(:product_already_in_category_message) { /Product already in Category!/ }

  context "POST /client/:client_id/add-product-to-list" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "when product exists" do
        let(:client) { Client.last }

        before do
          FactoryBot.create(:product, client: client)
        end

        context "when list exists" do
          let!(:product) { Product.last }

          before do
            FactoryBot.create(:list, client: client)
          end

          let(:params) {
            {
              product_id: product.id,
              list_id: List.last.id,
            }
          }

          context "when product and list are NOT associated yet" do
            it "should return status code 200" do
              post "/clients/#{client.id}/add-product-to-list", params: params

              expect(response.status).to be(200)
            end

            it "should create correct relation between product and list" do
              post "/clients/#{client.id}/add-product-to-list", params: params

              list = List.last

              expect(list.products.pluck(:id)).to include(product.id)
              expect(product.lists.pluck(:id)).to include(list.id)
            end
          end

          context "when product and list are associated yet" do
            let!(:list) { List.last }

            before do
              list.products << product
            end

            it "should return status code 422" do
              post "/clients/#{client.id}/add-product-to-list", params: params

              expect(response.status).to be(422)
            end

            it "should NOT create relation between product and list" do
              initial_association_count = ProductListAssociation.all.count

              post "/clients/#{client.id}/add-product-to-list", params: params

              new_association_count = ProductListAssociation.all.count

              expect(initial_association_count).to be(new_association_count)
            end

            it "should return an ERROR message" do
              post "/clients/#{client.id}/add-product-to-list", params: params

              expect(response_as_json["message"]).to match(product_already_in_list_message)
            end
          end
        end

        context "when list NOT exists" do
          let(:product) { Product.last }
          let(:invalid_list_id) { Faker::Number.between(999, 9999) }
          let(:params) {
            {
              product_id: product.id,
              list_id: Faker::Number.between(999, 9999),
            }
          }

          it "should return status code 404" do
            post "/clients/#{client.id}/add-product-to-list", params: params

            expect(response.status).to be(404)
          end

          it "should return an ERROR message" do
            post "/clients/#{client.id}/add-product-to-list", params: params

            expect(response_as_json["message"]).to match(list_not_found_message)
          end
        end
      end

      context "when product NOT exists" do
        let(:client) { Client.last }
        let(:invalid_product_id) { Faker::Number.between(999, 9999) }
        let(:params) {
          {
            product_id: invalid_product_id,
            list_id: Faker::Number.between(999, 9999),
          }
        }

        it "should return status code 404" do
          post "/clients/#{client.id}/add-product-to-list", params: params

          expect(response.status).to be(404)
        end

        it "should return an ERROR message" do
          post "/clients/#{client.id}/add-product-to-list", params: params

          expect(response_as_json["message"]).to match(product_not_found_message)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        post "/clients/#{invalid_client_id}/add-product-to-list"

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        post "/clients/#{invalid_client_id}/add-product-to-list"

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end

  context "DELETE /client/:client_id/remove-product-from-list" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "when product exists" do
        let(:client) { Client.last }

        before do
          FactoryBot.create(:product, client: client)
        end

        context "when list exists" do
          let!(:product) { Product.last }

          before do
            FactoryBot.create(:list, client: client)
          end

          let(:params) {
            {
              product_id: product.id,
              list_id: List.last.id,
            }
          }

          context "when product and list are associated yet" do
            let!(:list) { List.last }

            before do
              list.products << product
            end

            it "should return status code 200" do
              delete "/clients/#{client.id}/remove-product-from-list", params: params

              expect(response.status).to be(200)
            end

            it "should delete relation between product and list" do
              delete "/clients/#{client.id}/remove-product-from-list", params: params

              expect(list.products.pluck(:id)).to_not include(product.id)
              expect(product.lists.pluck(:id)).to_not include(list.id)
            end
          end

          context "when product and list are NOT associated yet" do
            let!(:list) { List.last }

            it "should return status code 404" do
              delete "/clients/#{client.id}/remove-product-from-list", params: params

              expect(response.status).to be(404)
            end

            it "should NOT delete relation between product and list" do
              initial_association_count = ProductListAssociation.all.count

              delete "/clients/#{client.id}/remove-product-from-list", params: params

              new_association_count = ProductListAssociation.all.count

              expect(initial_association_count).to be(new_association_count)
            end

            it "should return an ERROR message" do
              delete "/clients/#{client.id}/remove-product-from-list", params: params

              expect(response_as_json["message"]).to match(product_not_in_list_message)
            end
          end
        end

        context "when list NOT exists" do
          let(:product) { Product.last }
          let(:invalid_list_id) { Faker::Number.between(999, 9999) }
          let(:params) {
            {
              product_id: product.id,
              list_id: Faker::Number.between(999, 9999),
            }
          }

          it "should return status code 404" do
            delete "/clients/#{client.id}/remove-product-from-list", params: params

            expect(response.status).to be(404)
          end

          it "should return an ERROR message" do
            delete "/clients/#{client.id}/remove-product-from-list", params: params

            expect(response_as_json["message"]).to match(list_not_found_message)
          end
        end
      end

      context "when product NOT exists" do
        let(:client) { Client.last }
        let(:invalid_product_id) { Faker::Number.between(999, 9999) }
        let(:params) {
          {
            product_id: invalid_product_id,
            list_id: Faker::Number.between(999, 9999),
          }
        }

        it "should return status code 404" do
          delete "/clients/#{client.id}/remove-product-from-list", params: params

          expect(response.status).to be(404)
        end

        it "should return an ERROR message" do
          delete "/clients/#{client.id}/remove-product-from-list", params: params

          expect(response_as_json["message"]).to match(product_not_found_message)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        delete "/clients/#{invalid_client_id}/remove-product-from-list"

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        delete "/clients/#{invalid_client_id}/remove-product-from-list"

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end

  context "POST /client/:client_id/add-product-to-category" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "when product exists" do
        let(:client) { Client.last }

        before do
          FactoryBot.create(:product, client: client)
        end

        context "when category exists" do
          let!(:product) { Product.last }

          before do
            FactoryBot.create(:category, client: client)
          end

          let(:params) {
            {
              product_id: product.id,
              category_id: Category.last.id,
            }
          }

          context "when product and category are NOT associated yet" do
            it "should return status code 200" do
              post "/clients/#{client.id}/add-product-to-category", params: params

              expect(response.status).to be(200)
            end

            it "should create correct relation between product and category" do
              post "/clients/#{client.id}/add-product-to-category", params: params

              category = Category.last

              expect(category.products.pluck(:id)).to include(product.id)
              expect(product.categories.pluck(:id)).to include(category.id)
            end
          end

          context "when product and category are associated yet" do
            let!(:category) { Category.last }

            before do
              category.products << product
            end

            it "should return status code 422" do
              post "/clients/#{client.id}/add-product-to-category", params: params

              expect(response.status).to be(422)
            end

            it "should NOT create relation between product and category" do
              initial_association_count = ProductCategoryAssociation.all.count

              post "/clients/#{client.id}/add-product-to-category", params: params

              new_association_count = ProductCategoryAssociation.all.count

              expect(initial_association_count).to be(new_association_count)
            end

            it "should return an ERROR message" do
              post "/clients/#{client.id}/add-product-to-category", params: params

              expect(response_as_json["message"]).to match(product_already_in_category_message)
            end
          end
        end

        context "when category NOT exists" do
          let(:product) { Product.last }
          let(:invalid_category_id) { Faker::Number.between(999, 9999) }
          let(:params) {
            {
              product_id: product.id,
              category_id: Faker::Number.between(999, 9999),
            }
          }

          it "should return status code 404" do
            post "/clients/#{client.id}/add-product-to-category", params: params

            expect(response.status).to be(404)
          end

          it "should return an ERROR message" do
            post "/clients/#{client.id}/add-product-to-category", params: params

            expect(response_as_json["message"]).to match(category_not_found_message)
          end
        end
      end

      context "when product NOT exists" do
        let(:client) { Client.last }
        let(:invalid_product_id) { Faker::Number.between(999, 9999) }
        let(:params) {
          {
            product_id: invalid_product_id,
            category_id: Faker::Number.between(999, 9999),
          }
        }

        it "should return status code 404" do
          post "/clients/#{client.id}/add-product-to-category", params: params

          expect(response.status).to be(404)
        end

        it "should return an ERROR message" do
          post "/clients/#{client.id}/add-product-to-category", params: params

          expect(response_as_json["message"]).to match(product_not_found_message)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        post "/clients/#{invalid_client_id}/add-product-to-category"

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        post "/clients/#{invalid_client_id}/add-product-to-category"

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end

  context "DELETE /client/:client_id/remove-product-from-category" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "when product exists" do
        let(:client) { Client.last }

        before do
          FactoryBot.create(:product, client: client)
        end

        context "when category exists" do
          let!(:product) { Product.last }

          before do
            FactoryBot.create(:category, client: client)
          end

          let(:params) {
            {
              product_id: product.id,
              category_id: Category.last.id,
            }
          }

          context "when product and category are associated yet" do
            let!(:category) { Category.last }

            before do
              category.products << product
            end

            it "should return status code 200" do
              delete "/clients/#{client.id}/remove-product-from-category", params: params

              expect(response.status).to be(200)
            end

            it "should delete relation between product and category" do
              delete "/clients/#{client.id}/remove-product-from-category", params: params

              expect(category.products.pluck(:id)).to_not include(product.id)
              expect(product.categories.pluck(:id)).to_not include(category.id)
            end
          end

          context "when product and category are NOT associated yet" do
            let!(:category) { Category.last }

            it "should return status code 404" do
              delete "/clients/#{client.id}/remove-product-from-category", params: params

              expect(response.status).to be(404)
            end

            it "should NOT delete relation between product and category" do
              initial_association_count = ProductCategoryAssociation.all.count

              delete "/clients/#{client.id}/remove-product-from-category", params: params

              new_association_count = ProductCategoryAssociation.all.count

              expect(initial_association_count).to be(new_association_count)
            end

            it "should return an ERROR message" do
              delete "/clients/#{client.id}/remove-product-from-category", params: params

              expect(response_as_json["message"]).to match(product_not_in_category_message)
            end
          end
        end

        context "when category NOT exists" do
          let(:product) { Product.last }
          let(:invalid_category_id) { Faker::Number.between(999, 9999) }
          let(:params) {
            {
              product_id: product.id,
              category_id: Faker::Number.between(999, 9999),
            }
          }

          it "should return status code 404" do
            delete "/clients/#{client.id}/remove-product-from-category", params: params

            expect(response.status).to be(404)
          end

          it "should return an ERROR message" do
            delete "/clients/#{client.id}/remove-product-from-category", params: params

            expect(response_as_json["message"]).to match(category_not_found_message)
          end
        end
      end

      context "when product NOT exists" do
        let(:client) { Client.last }
        let(:invalid_product_id) { Faker::Number.between(999, 9999) }
        let(:params) {
          {
            product_id: invalid_product_id,
            category_id: Faker::Number.between(999, 9999),
          }
        }

        it "should return status code 404" do
          delete "/clients/#{client.id}/remove-product-from-category", params: params

          expect(response.status).to be(404)
        end

        it "should return an ERROR message" do
          delete "/clients/#{client.id}/remove-product-from-category", params: params

          expect(response_as_json["message"]).to match(product_not_found_message)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        delete "/clients/#{invalid_client_id}/remove-product-from-category"

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        delete "/clients/#{invalid_client_id}/remove-product-from-category"

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end
end