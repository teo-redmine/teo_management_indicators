require_dependency 'indicadores_controller'

# Se importan las clases de utilidad
require 'indicators_utils/colors'
require 'indicators_utils/chart_view'
require 'indicators_utils/settings'
require 'indicators_utils/issue_fields'
require 'charts/grafica_actuaciones_en_curso'
require 'charts/grafica_importes_ejecutados'
require 'charts/grafica_actuaciones_issues'


module TeoManagementIndicatorsUtilities

  def self.included(base)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    $CONST_PROY = "projects"
    $CONST_ISSUE = "issues"
    $CONST_OT = Tracker.where('name like ?', '%OT%')[0]
    $CONST_ID_PROJ = ""
    $COSNT_IS_SISINF = false
    $SPLIT_CHAR = "##_#"
    $ID_CONST_CUSTFIELD = nil

    def cargaGraficasProyecto
      logger.info('Dentro de cargaGraficasProyecto')
      calculaGraficas($CONST_PROY)
    end

    def cargaGraficasPeticion
      logger.info('Dentro de cargaGraficasPeticion')
      tipospeticiong1n1issues = Tracker.where({id: Setting.plugin_teo_management_indicators['tipo_peticion_g1n1_issues']})
      if !tipospeticiong1n1issues.nil? && tipospeticiong1n1issues.any?
        calculaGraficas($CONST_ISSUE)
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

      $CONST_ID_PROJ = @project.identifier

      tracker_fields = Tracker::CORE_FIELDS
      proyectoPadre = whereProject[0]
      
      while proyectoPadre.parent_id != nil do
         proyectoPadre = Project.where({id: proyectoPadre.parent_id})[0]
      end

      begin
        if !procedencia.eql?($CONST_ISSUE)
          $COSNT_IS_SISINF = proyectoPadre.identifier.downcase.include?(I18n.t("proy_sis_info").downcase)
          if !$COSNT_IS_SISINF
            Charts::GraficaActuacionesEnCurso.calculaGraficaActuacionesEnCurso(whereProject, tracker_fields, @settings, @chart_view)
          end

          if !procedencia.eql?($CONST_PROY)
            esTipoContrato = proyectoPadre.identifier.downcase.include?(I18n.t("proy_contrato").downcase)
            Charts::GraficaImportesEjecutados.calculaGraficaImportesEjecutados(whereProject, tracker_fields, @settings, @chart_view, esTipoContrato, $COSNT_IS_SISINF)
            if esTipoContrato && procedencia == 'indicadores'
              Charts::GraficaSectoresContratos.calculaGraficaSectoresContratos(whereProject, tracker_fields, @settings, @chart_view)
            end
          end
        else 
          Charts::GraficaActuacionesIssues.calculaGraficaActuacionesIssues(whereProject, tracker_fields, @settings, @chart_view, @issue.id)
        end
      rescue
        Rails.logger.error('ERROR al montar una de las graficas.')
      end
    end
  end
end
IndicadoresController.send(:include, TeoManagementIndicatorsUtilities::InstanceMethods)