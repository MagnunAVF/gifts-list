Jets.application.routes.draw do
  root "jets/public#show"
  resources :clients do
    resources :products
    resources :lists
    resources :categories

    # Product Associations
    post "add-product-to-list", to: "products_associations#add_product_to_list"
    delete "remove-product-from-list", to: "products_associations#remove_product_from_list"
    post "add-product-to-category", to: "products_associations#add_product_to_category"
    delete "remove-product-from-category", to: "products_associations#remove_product_from_category"

    # Product Queries
    get "find-products-in-list", to: "product_queries#find_products_in_list"
    get "find-products-in-category", to: "product_queries#find_products_in_category"
  end
end
