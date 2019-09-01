require "spec_helper"

describe CategoriesController, type: :controller do
  let(:category_not_found_message) { /Couldn't find Category/ }
  let(:without_categories_message) { /Couldn't find categories !/ }
  let(:invalid_attributtes_message) { /Validation failed/ }
  let(:update_without_attributes) { /Without attributes to update!/ }
  let(:client_not_found_message) { /Client not found!/ }
  let(:parent_category_not_found_message) { /Parent Category not found!/ }

  context "GET /clients/:client_id/categories" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "when has categories in db" do
        let(:page_number) { 1 }
        let(:client) { Client.last }

        before do
          FactoryBot.create_list(:category, page_number * 4, client: client)
        end

        it "should return status code 200" do
          get "/clients/#{client.id}/categories", page: page_number

          expect(response.status).to be(200)
        end

        it "should return n categories, where n is the number of registers per page" do
          get "/clients/#{client.id}/categories", page: page_number

          db_paginated_categories = Category.page(page_number).per(ENV["PAGE_SIZE"])

          expect(response_as_json).not_to be_empty
          expect(response_as_json.count).not_to be(Category.count)
          expect(response_as_json.count).to be(ENV["PAGE_SIZE"].to_i)
          expect(response_as_json).to eq(db_paginated_categories.as_json)
        end
      end

      context "when HAS NOT categories in db" do
        let(:client) { Client.last }

        it "should return status code 404" do
          get "/clients/#{client.id}/categories"

          expect(response.status).to be(404)
        end

        it "should return an ERROR message" do
          get "/clients/#{client.id}/categories"

          expect(response_as_json["message"]).to match(without_categories_message)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        get "/clients/#{invalid_client_id}/categories"

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        get "/clients/#{invalid_client_id}/categories"

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end

  context "GET /clients/:client_id/categories/:id" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "when category exists" do
        let(:client) { Client.last }

        before do
          FactoryBot.create(:category, client: client)
        end

        it "should return status code 200" do
          get "/clients/#{client.id}/categories/:id", id: Category.last.id

          expect(response.status).to be(200)
        end

        it "should return the required category" do
          category = Category.last

          get "/clients/#{client.id}/categories/:id", id: category.id

          expect(response_as_json).to eq(category.as_json)
        end
      end

      context "when category NOT exists" do
        let(:client) { Client.last }
        let(:invalid_id) { Faker::Number.between(999, 9999) }

        before do
          get "/clients/#{client.id}/categories/:id", id: invalid_id
        end

        it "should return status code 404" do
          expect(response.status).to be(404)
        end

        it "should return an ERROR message" do
          expect(response_as_json["message"]).to match(category_not_found_message)
          expect(response_as_json["message"]).to match(invalid_id.to_s)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }
      let(:invalid_category_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        get "/clients/#{invalid_client_id}/categories/:id", id: invalid_category_id

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        get "/clients/#{invalid_client_id}/categories/:id", id: invalid_category_id

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end

  context "POST /clients/:client_id/categories/" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "with valid attributes" do
        context "without parent category" do
          let(:client) { Client.last }
          let(:valid_attributes) {
            FactoryBot.build(
              :category,
              client_id: client.id,
              parent_category_id: nil,
            ).as_json.except("id")
          }
          let!(:initial_categories_count) { Category.all.count }

          before do
            post "/clients/#{client.id}/categories", params: valid_attributes
          end

          it "should return status code 201" do
            expect(response.status).to be(201)
          end

          it "should create a new category" do
            expect(Category.all.count).to be(initial_categories_count + 1)
          end

          it "should return the new category" do
            db_category = Category.last

            expect(response_as_json).to eq(db_category.as_json)
          end
        end

        context "with parent category" do
          context "when parent category exists" do
            let!(:client) { Client.last }
            let!(:category) {
              FactoryBot.create(
                :category,
                client_id: client.id,
              )
            }
            let(:valid_attributes) {
              FactoryBot.build(
                :category,
                client_id: client.id,
                parent_category_id: category.id,
              ).as_json.except("id")
            }
            let!(:initial_categories_count) { Category.all.count }

            before do
              post "/clients/#{client.id}/categories", params: valid_attributes
            end

            it "should return status code 201" do
              expect(response.status).to be(201)
            end

            it "should create a new category" do
              expect(Category.all.count).to be(initial_categories_count + 1)
            end

            it "should return the new category" do
              db_category = Category.last

              expect(response_as_json).to eq(db_category.as_json)
            end

            it "should set correct reference to parent category" do
              db_category = Category.last

              expect(response_as_json["parent_category_id"]).to eq(db_category.as_json["parent_category_id"])
            end
          end

          context "when parent category NOT exists" do
            let(:client) { Client.last }
            let(:invalid_category_id) { Faker::Number.between(999, 9999) }
            let(:valid_attributes) {
              FactoryBot.build(
                :category,
                client_id: client.id,
                parent_category_id: :invalid_category_id,
              ).as_json.except("id")
            }
            let!(:initial_categories_count) { Category.all.count }

            before do
              post "/clients/#{client.id}/categories", params: valid_attributes
            end

            it "should return status code 404" do
              expect(response.status).to be(404)
            end

            it "should return an ERROR message" do
              expect(response_as_json["message"]).to match(parent_category_not_found_message)
            end
          end
        end
      end

      context "with INVALID attributes" do
        let(:client) { Client.last }
        let!(:initial_categories_count) { Category.all.count }
        let(:invalid_attributes) { { name: nil } }

        before do
          post "/clients/#{client.id}/categories", params: invalid_attributes
        end

        it "should return status code 422" do
          expect(response.status).to be(422)
        end

        it "should return an ERROR message" do
          expect(response_as_json["message"]).to match(invalid_attributtes_message)
        end

        it "should NOT create a new category" do
          expect(Category.all.count).to be(initial_categories_count)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        post "/clients/#{invalid_client_id}/categories"

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        post "/clients/#{invalid_client_id}/categories"

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end

  context "DELETE /clients/:client_id/categories/:id" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "when category exists" do
        let(:client) { Client.last }
        let!(:initial_categories_count) { Category.all.count }

        before do
          FactoryBot.create(:category, client: client)
        end

        it "should return status code 200" do
          delete "/clients/#{client.id}/categories/:id", id: Category.last.id

          expect(response.status).to be(200)
        end

        it "should delete the category" do
          category = Category.last
          initial_categories_count = Category.all.count

          delete "/clients/#{client.id}/categories/:id", id: category.id

          expect {
            Category.find(category.id)
          }.to raise_error(ActiveRecord::RecordNotFound)

          expect(Category.all.count).to be(initial_categories_count - 1)
        end
      end

      context "when category NOT exists" do
        let(:client) { Client.last }
        let(:invalid_id) { Faker::Number.between(999, 9999) }

        before do
          delete "/clients/#{client.id}/categories/:id", id: invalid_id
        end

        it "should return status code 404" do
          expect(response.status).to be(404)
        end

        it "should return an ERROR message" do
          expect(response_as_json["message"]).to match(category_not_found_message)
          expect(response_as_json["message"]).to match(invalid_id.to_s)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }
      let(:invalid_category_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        delete "/clients/#{invalid_client_id}/categories/:id", id: invalid_category_id

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        delete "/clients/#{invalid_client_id}/categories/:id", id: invalid_category_id

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end

  context "PUT /clients/:client_id/categories/:id" do
    context "when client exists" do
      before do
        FactoryBot.create(:client)
      end

      context "when category exists" do
        let(:client) { Client.last }

        before do
          FactoryBot.create(:category, client: client)
        end

        context "and with valid attributes" do
          context "without parent category" do
            let!(:category) { create(:category) }
            let(:valid_attributes) {
              FactoryBot.build(:category).as_json.except("id")
            }

            before do
              put "/clients/#{client.id}/categories/:id", id: category.id, params: valid_attributes
            end

            it "should return status code 200" do
              expect(response.status).to be(200)
            end

            it "should update the category" do
              db_category = Category.find(category.id)

              expect(response_as_json).to eq(db_category.as_json)
            end
          end

          context "with parent category" do
            context "when parent category exists" do
              let!(:client) { Client.last }
              let!(:category) {
                FactoryBot.create(
                  :category,
                  client_id: client.id,
                )
              }
              let(:valid_attributes) {
                FactoryBot.build(
                  :category,
                  client_id: client.id,
                  parent_category_id: category.id,
                ).as_json.except("id")
              }

              before do
                put "/clients/#{client.id}/categories/:id", id: category.id, params: valid_attributes
              end

              it "should return status code 200" do
                expect(response.status).to be(200)
              end

              it "should return the updated category" do
                db_category = Category.last

                expect(response_as_json).to eq(db_category.as_json)
              end

              it "should set correct reference to parent category" do
                db_category = Category.last

                expect(response_as_json["parent_category_id"]).to eq(db_category.as_json["parent_category_id"])
              end
            end

            context "when parent category NOT exists" do
              let!(:category) { create(:category) }
              let(:client) { Client.last }
              let(:invalid_category_id) { Faker::Number.between(999, 9999) }
              let(:valid_attributes) {
                FactoryBot.build(
                  :category,
                  client_id: client.id,
                  parent_category_id: :invalid_category_id,
                ).as_json.except("id")
              }
              let!(:initial_categories_count) { Category.all.count }

              before do
                put "/clients/#{client.id}/categories/:id", id: category.id, params: valid_attributes
              end

              it "should return status code 404" do
                expect(response.status).to be(404)
              end

              it "should return an ERROR message" do
                expect(response_as_json["message"]).to match(parent_category_not_found_message)
              end
            end
          end
        end

        context "and WITHOUT attributes to update" do
          let(:no_attributes) { {} }
          let(:category) { Category.last }

          before do
            put "/clients/#{client.id}/categories/:id", id: category.id, params: no_attributes
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
          let(:category) { Category.last }

          before do
            put "/clients/#{client.id}/categories/:id", id: category.id, params: invalid_attributes
          end

          it "should return status code 422" do
            expect(response.status).to be(422)
          end

          it "should return an ERROR message" do
            expect(response_as_json["message"]).to match(invalid_attributtes_message)
          end
        end
      end

      context "when category NOT exists" do
        let(:client) { Client.last }
        let(:invalid_id) { Faker::Number.between(999, 9999) }

        before do
          put "/clients/#{client.id}/categories/:id", id: invalid_id
        end

        it "should return status code 404" do
          expect(response.status).to be(404)
        end

        it "should return an ERROR message" do
          expect(response_as_json["message"]).to match(category_not_found_message)
          expect(response_as_json["message"]).to match(invalid_id.to_s)
        end
      end
    end

    context "when client NOT exists" do
      let(:invalid_client_id) { Faker::Number.between(999, 9999) }
      let(:invalid_category_id) { Faker::Number.between(999, 9999) }

      it "should return status code 404" do
        put "/clients/#{invalid_client_id}/categories/:id", id: invalid_category_id

        expect(response.status).to be(404)
      end

      it "should return an ERROR message" do
        put "/clients/#{invalid_client_id}/categories/:id", id: invalid_category_id

        expect(response_as_json["message"]).to match(client_not_found_message)
      end
    end
  end
end
