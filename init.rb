# encoding: utf-8

# Se incluye el codigo del plugin a los controladores de Settings y Projects
require 'teo_management_indicators'
# Para no pisar la vista y evitar conflictos con otros plugins,
# la vista es modificada por un hook
require 'indicators_hook_listener'

ActionDispatch::Callbacks.to_prepare do
  SettingsController.send(:include, TeoManagementIndicatorsSettings)
  IndicadoresController.send(:include, TeoManagementIndicatorsUtilities)
end

Redmine::Plugin.register :teo_management_indicators do
  name 'Teo Management Indicators plugin'
  author 'Junta de Andalucía. Philip Watfe Sánchez. Juan Antonio Blanco Robles. Abraham Castro Expósito'
  description 'Este plugin añade gestión de indicadores económicos'
  version '1.1.0'
  url 'https://github.com/teo-redmine/teo_management_indicators.git'
  author_url 'http://www.juntadeandalucia.es'

  project_module :indicadores do
    permission :view_indicadores, :indicadores => :index
  end

  menu :project_menu, :indicadores, { :controller => 'indicadores', :action => 'index' }, :caption => 'Indicadores', :after => :activity, :param => :project_id

  settings :default => {'empty' => true}, :partial => 'settings/indicadores_settings'
end

# Con esto hacemos que los métodos de TeoManagementIndicatorsUtilities
# se puedan llamar dessde el partial _indicadores.html.erb (y desde cualquier vista)
ApplicationHelper.send(:include, TeoManagementIndicatorsUtilities)
