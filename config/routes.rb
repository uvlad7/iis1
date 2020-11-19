Rails.application.routes.draw do
  resources :quizzes, only: [:create, :new, :show, :update]
  root to: 'quizzes#new'
end
