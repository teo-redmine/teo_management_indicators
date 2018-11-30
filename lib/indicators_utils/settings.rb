module IndicatorsUtils
  class Settings
    def initialize
      ### GRAFICA 1************************************************************************************ ###
      @tipospeticiong1n1 = Tracker.where({id: Setting.plugin_teo_management_indicators['tipo_peticion_g1n1']})
      @tipospeticiong1n2 = Tracker.where({id: Setting.plugin_teo_management_indicators['tipo_peticion_g1n2']})
      @estadosAcsg1n1 = Setting.plugin_teo_management_indicators['estado_g1n1']
      @estadosOtsg1n2 = Setting.plugin_teo_management_indicators['estado_g1n2']
      @estadosEncursoOtsg1n2 = Setting.plugin_teo_management_indicators['estado_encurso_g1n2']
      @importeg1n1 = Setting.plugin_teo_management_indicators['importe_g1n1']
      @importe1g1n2 = Setting.plugin_teo_management_indicators['importe1_g1n2']
      @importe2g1n2 = Setting.plugin_teo_management_indicators['importe2_g1n2']
      @fechaIniciog1n1 = Setting.plugin_teo_management_indicators['fecha_inicio_g1n1']
      @fechaFing1n1 = Setting.plugin_teo_management_indicators['fecha_fin_g1n1']
      @porcentajeg1n2 = Setting.plugin_teo_management_indicators['porcentaje_g1n2']
      @tipospeticiong1n1issues = Tracker.where({id: Setting.plugin_teo_management_indicators['tipo_peticion_g1n1_issues']})

      ### GRAFICA 2************************************************************************************ ###
      @agruparporg2 = Setting.plugin_teo_management_indicators['agrupar_por_g2']
      @tipospeticiong2n1 = Tracker.where({id: Setting.plugin_teo_management_indicators['tipo_peticion_g2n1']})
      @tipospeticiong2n2 = Tracker.where({id: Setting.plugin_teo_management_indicators['tipo_peticion_g2n2']})
      @estadosAcsg2n1 = Setting.plugin_teo_management_indicators['estado_g2n1']
      @estadosOtsg2n2 = Setting.plugin_teo_management_indicators['estado_g2n2']
      @importe1g2n2 = Setting.plugin_teo_management_indicators['importe1_g2n2']
      @importe2g2n2 = Setting.plugin_teo_management_indicators['importe2_g2n2']
      @fechaFing2n2 = Setting.plugin_teo_management_indicators['fecha_fin_g2n2']
      @actLegendg2 = Setting.plugin_teo_management_indicators['act_legend_g2']      

      ### GRAFICA 3************************************************************************************ ###
      @tipospeticiong3n1 = Tracker.where({id: Setting.plugin_teo_management_indicators['tipo_peticion_g3n1']})      
      @estadosAcsg3n1 = Setting.plugin_teo_management_indicators['estado_g3n1']
      @tipospeticiong3n2 = Tracker.where({id: Setting.plugin_teo_management_indicators['tipo_peticion_g3n2']})
      @importe1g3n2 = Setting.plugin_teo_management_indicators['importe1_g3n2']
      @importe2g3n2 = Setting.plugin_teo_management_indicators['importe2_g3n2']
      @agruparporg3 = Setting.plugin_teo_management_indicators['agrupar_por_g3']

      ### GRAFICA 4************************************************************************************ ###
      @tipospeticiong4n1 = Tracker.where({id: Setting.plugin_teo_management_indicators['tipo_peticion_g4n1']})      
      @estadosg4n1 = Setting.plugin_teo_management_indicators['estado_g4n1']
      @campo4n1 = IssueCustomField.where({id: Setting.plugin_teo_management_indicators['campo_4n1']})
      @agruparporg4 = Setting.plugin_teo_management_indicators['agrupar_por_g4']
      @limit_g4_1 = Setting.plugin_teo_management_indicators['limit_g4_1']
      @limit_g4_2 = Setting.plugin_teo_management_indicators['limit_g4_2']
      @limit_g4_3 = Setting.plugin_teo_management_indicators['limit_g4_3']
      @limit_g4_4 = Setting.plugin_teo_management_indicators['limit_g4_4']
      @limit_g4_5 = Setting.plugin_teo_management_indicators['limit_g4_5']

      ### GRAFICA 5************************************************************************************ ###
      @tipospeticiong5n1 = Tracker.where({id: Setting.plugin_teo_management_indicators['tipo_peticion_g5n1']})      
      @estadosg5n1 = Setting.plugin_teo_management_indicators['estado_g5n1']
      @campo5n1 = IssueCustomField.where({id: Setting.plugin_teo_management_indicators['campo_5n1']})
      @agruparporg5 = Setting.plugin_teo_management_indicators['agrupar_por_g5']
      @limit_g5_1 = Setting.plugin_teo_management_indicators['limit_g5_1']
      @limit_g5_2 = Setting.plugin_teo_management_indicators['limit_g5_2']
      @limit_g5_3 = Setting.plugin_teo_management_indicators['limit_g5_3']
      @limit_g5_4 = Setting.plugin_teo_management_indicators['limit_g5_4']
      @limit_g5_5 = Setting.plugin_teo_management_indicators['limit_g5_5']

      ### GRAFICA GENERAL************************************************************************************ ###
      @actLinkg2 = Setting.plugin_teo_management_indicators['act_link']
      @activarActualizar = Setting.plugin_teo_management_indicators['act_actu']
    end

    ### GRAFICA 1 ************************************************************************************ ###
    def tipospeticiong1n1
      @tipospeticiong1n1
    end

    def tipospeticiong1n2
      @tipospeticiong1n2
    end

    def estadosAcsg1n1
      @estadosAcsg1n1
    end

    def estadosOtsg1n2
      @estadosOtsg1n2
    end

    def estadosEncursoOtsg1n2
      @estadosEncursoOtsg1n2
    end

    def importeg1n1
      @importeg1n1
    end

    def importe1g1n2
      @importe1g1n2
    end

    def importe2g1n2
      @importe2g1n2
    end

    def fechaIniciog1n1
      @fechaIniciog1n1
    end

    def fechaFing1n1
      @fechaFing1n1
    end

    def porcentajeg1n2
      @porcentajeg1n2
    end

    def tipospeticiong1n1issues
      @tipospeticiong1n1issues
    end

    ### GRAFICA 2 ************************************************************************************ ###
    def agruparporg2
      @agruparporg2
    end

    def tipospeticiong2n1
      @tipospeticiong2n1
    end

    def tipospeticiong2n2
      @tipospeticiong2n2
    end

    def estadosAcsg2n1
      @estadosAcsg2n1
    end

    def estadosOtsg2n2
      @estadosOtsg2n2
    end

    def importe1g2n2
      @importe1g2n2
    end

    def importe2g2n2
      @importe2g2n2
    end

    def fechaFing2n2
      @fechaFing2n2
    end

    def actLegendg2
      @actLegendg2
    end

    ### GRAFICA 3 ************************************************************************************ ###
    def tipospeticiong3n1
      @tipospeticiong3n1
    end

    def estadosAcsg3n1
      @estadosAcsg3n1
    end

    def tipospeticiong3n2
      @tipospeticiong3n2
    end

    def importe1g3n2
      @importe1g3n2
    end

    def importe2g3n2
      @importe2g3n2
    end

    def agruparporg3
      @agruparporg3
    end

    ### GRAFICA 4 ************************************************************************************ ###
    def tipospeticiong4n1
      @tipospeticiong4n1
    end

    def estadosg4n1
      @estadosg4n1
    end

    def campo4n1
      @campo4n1
    end

    def agruparporg4
      @agruparporg4
    end

    def agruparporg4
      @agruparporg4
    end

    def limit_g4_1
      @limit_g4_1
    end

    def limit_g4_1=(limit_g4_1)
      @limit_g4_1 = limit_g4_1    
    end

    def limit_g4_2
      @limit_g4_2
    end

    def limit_g4_2=(limit_g4_2)
      @limit_g4_2 = limit_g4_2
    end

    def limit_g4_3
      @limit_g4_3
    end

    def limit_g4_3=(limit_g4_3)
      @limit_g4_3 = limit_g4_3
    end

    def limit_g4_4
      @limit_g4_4
    end

    def limit_g4_4=(limit_g4_4)
      @limit_g4_4 = limit_g4_4
    end

    def limit_g4_5
      @limit_g4_5
    end

    def limit_g4_5=(limit_g4_5)
      @limit_g4_5 = limit_g4_5
    end

    ### GRAFICA 5 ************************************************************************************ ###
    def tipospeticiong5n1
      @tipospeticiong5n1
    end

    def estadosg5n1
      @estadosg5n1
    end

    def campo5n1
      @campo5n1
    end

    def agruparporg5
      @agruparporg5
    end

    def limit_g5_1
      @limit_g5_1
    end

    def limit_g5_1=(limit_g5_1)
      @limit_g5_1 = limit_g5_1
    end

    def limit_g5_2
      @limit_g5_2
    end

    def limit_g5_2=(limit_g5_2)
      @limit_g5_2 = limit_g5_2
    end

    def limit_g5_3
      @limit_g5_3
    end

    def limit_g5_3=(limit_g5_3)
      @limit_g5_3 = limit_g5_3
    end

    def limit_g5_4
      @limit_g5_4
    end

    def limit_g5_4=(limit_g5_4)
      @limit_g5_4 = limit_g5_4
    end

    def limit_g5_5
      @limit_g5_5
    end

    def limit_g5_5=(limit_g5_5)
      @limit_g5_5 = limit_g5_5
    end

    ### GRAFICA GENERAL************************************************************************************ ###
    def actLinkg2
      @actLinkg2
    end

    def activarActualizar
      @activarActualizar
    end
  end
end
