Jets.application.routes.draw do
  root "jets/public#show"
  resources :clients
end
