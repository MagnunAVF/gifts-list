Jets.application.routes.draw do
  root "jets/public#show"
  resources :clients do
    resources :products
    resources :lists
    resources :categories
  end
end
