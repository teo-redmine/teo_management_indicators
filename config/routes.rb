# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'indicadores', :to => 'indicadores#index'
get 'indicadores/actissues/:project_id', :to => 'indicadores#actualizar', as: :indicadores_actissues2
