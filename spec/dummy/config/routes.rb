Rails.application.routes.draw do
  mount Casino::Engine => '/', :as => 'casino'
end
