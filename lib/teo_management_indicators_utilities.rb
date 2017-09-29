require_dependency 'indicadores_controller'

# Se importan las clases de utilidad
require 'indicators_utils/colors'
require 'indicators_utils/chart_view'
require 'indicators_utils/settings'
require 'indicators_utils/issue_fields'
require 'charts/grafica_actuaciones_en_curso'
require 'charts/grafica_importes_ejecutados'

module TeoManagementIndicatorsUtilities

  def self.included(base)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def cargaGraficasProyecto
      logger.info('Dentro de cargaGraficasProyecto')

      calculaGraficas('projects')
    end

    def cargaGraficasPeticion
      logger.info('Dentro de cargaGraficasPeticion')

      tipospeticiong1n1issues = Tracker.where({id: Setting.plugin_teo_management_indicators['tipo_peticion_g1n1_issues']})

      if !tipospeticiong1n1issues.nil? && tipospeticiong1n1issues.any?
        calculaGraficas('issues')
      end
    end

    def calculaGraficas(procedencia)
      logger.info('Dentro de calculaGraficas(' + procedencia + ')')

      # Se carga la configuración
      @settings = IndicatorsUtils::Settings.new

      # Se inicializan los datos de las gráficas
      @chart_view = IndicatorsUtils::ChartView.new
      @chart_view.set_procedencia(procedencia)

      # Se prepara la condicion para mirar al proyecto y a sus hijos
      condicion = @project.project_condition(true)

      whereProject = Project.where(condicion)

      tracker_fields = Tracker::CORE_FIELDS

      Charts::GraficaActuacionesEnCurso.calculaGraficaActuacionesEnCurso(whereProject, tracker_fields, @settings, @chart_view)

      Charts::GraficaImportesEjecutados.calculaGraficaImportesEjecutados(whereProject, tracker_fields, @settings, @chart_view)
    end
  end
end

IndicadoresController.send(:include, TeoManagementIndicatorsUtilities::InstanceMethods)