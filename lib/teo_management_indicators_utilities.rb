require_dependency 'indicadores_controller'

module TeoManagementIndicatorsUtilities

  def self.included(base)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def cargaGraficasProyecto
      logger.info('Dentro de cargaGraficasProyecto')
      if User.current.allowed_to?(:view_indicadores, @project, :global => true)
        get_settings
        calculaGraficas('projects')
      end
    end

    def get_settings
      logger.info('Dentro de get_settings')
      @settings = Setting.plugin_teo_management_indicators
    end

    def calculaGraficas(procedencia)
      logger.info('Dentro de calculaGraficas(' + procedencia + ')')
      tipopeticiong1n1 = ""
      tipopeticiong1n2 = ""
      issuesOts = Array.new
      issueStatusOtsG1 = Array.new
      issueStatusOtsInProcess = Array.new

      # Se reciben los parametros de la configuracion
      # y se prepara la grafica de estado de actuaciones "en curso"
      logger.info('Se reciben los parametros de la configuracion y se prepara la grafica de estado de actuaciones "en curso"')

      tipospeticiong1n1 = Tracker.where({id: @settings['tipo_peticion_g1n1']})
      tipospeticiong1n2 = Tracker.where({id: @settings['tipo_peticion_g1n2']})
      estadosAcsg1n1 = @settings['estado_g1n1']
      estadosOtsg1n2 = @settings['estado_g1n2']
      estadosEncursoOtsg1n2 = @settings['estado_encurso_g1n2']
      importeg1n1 = @settings['importe_g1n1']
      importe1g1n2 = @settings['importe1_g1n2']
      importe2g1n2 = @settings['importe2_g1n2']
      fechaIniciog1n1 = @settings['fecha_inicio_g1n1']
      fechaFing1n1 = @settings['fecha_fin_g1n1']
      porcentajeg1n2 = @settings['porcentaje_g1n2']

      if tipospeticiong1n1 != nil && !tipospeticiong1n1.empty?
        tipopeticiong1n1 = tipospeticiong1n1[0]
      end

      if tipospeticiong1n2 != nil && !tipospeticiong1n2.empty?
        tipopeticiong1n2 = tipospeticiong1n2[0]
      end

      if estadosOtsg1n2 != nil && !estadosOtsg1n2.empty?
        issueStatusOtsG1 = IssueStatus.where({id: estadosOtsg1n2})
      end

      if estadosEncursoOtsg1n2 != nil
        issueStatusOtsInProcess = IssueStatus.where({id: estadosEncursoOtsg1n2})
      end

      @mapaG1 = Hash.new

      # Se prepara la condicion para mirar al proyecto y a sus hijos
      condicion = @project.project_condition(true)

      whereProject = Project.where(condicion)

      tracker_fields = Tracker::CORE_FIELDS

      # Se obtienen las AC con el estado indicado
      logger.info('Se obtienen las AC con el estado indicado (G1)')
      @acsG1 = Issue.where({project: whereProject, tracker: tipopeticiong1n1, status: estadosAcsg1n1})

      importeAC = 0
      @fechaInicio = nil
      @fechaFin = nil
      @fechaHoy = Date.today

      if @acsG1 == nil || @acsG1.empty?
        logger.info('No se encontraron ACs (G1))')
        issuesOts = Issue.where({project: whereProject, tracker: tipopeticiong1n2})
      else
        logger.info('Se encontraron ACs, se continúa con los cálculos (G1))')

        campoImporteg1n1 = IssueCustomField.where({id: (importeg1n1).sub("core__", '').sub("custom__", '')})
        campoFechaIniciog1n1 = IssueCustomField.where({id: (fechaIniciog1n1).sub("core__", '').sub("custom__", '')})
        campoFechaFing1n1 = IssueCustomField.where({id: (fechaFing1n1).sub("core__", '').sub("custom__", '')})


        # Por cada AC se obtendrán las OT y se agruparán por su estado
        logger.info('Por cada AC se obtendrán las OT y se agruparán por su estado (G1)')
        @acsG1.each do |ac|
          importeACCore = nil
          fechaInicioCore = nil
          fechaFinCore = nil

          if tracker_fields != nil && !tracker_fields.empty?
            tracker_fields.each do |field|
              if ("core__" + field).sub(/_id$/, '') == importeg1n1
                importeACCore = eval("ac." + (importeg1n1).sub("core__", ''))
              end

              if ("core__" + field).sub(/_id$/, '') == fechaIniciog1n1
                fechaInicioCore = eval("ac." + (fechaIniciog1n1).sub("core__", ''))
              end

              if ("core__" + field).sub(/_id$/, '') == fechaFing1n1
                fechaFinCore = eval("ac." + (fechaFing1n1).sub("core__", ''))
              end
            end
          end

          if importeACCore != nil
            importeAC = importeACCore
          end

          if fechaInicioCore != nil && (@fechaInicio == nil || @fechaInicio > fechaInicioCore)
            @fechaInicio = fechaInicioCore
          end

          if fechaFinCore != nil && (@fechaFin == nil || @fechaFin > fechaFinCore)
            @fechaFin = fechaFinCore
          end

          # Se obtiene el importe que se usará como referencia para calcular los porcentajes por estado
          logger.info('Se obtiene el importe que se usará como referencia para calcular los porcentajes por estado')
          custom_field_values_ac = ac.custom_field_values

          if custom_field_values_ac != nil && !custom_field_values_ac.empty?
            for cfv_ac in custom_field_values_ac
              if campoImporteg1n1 != nil && !campoImporteg1n1.empty? && campoImporteg1n1[0] != nil && cfv_ac.custom_field_id == campoImporteg1n1[0].id && cfv_ac.value != nil && cfv_ac.value != 0
                importeAC += cfv_ac.value.to_i
              end

              if campoFechaIniciog1n1 != nil && !campoFechaIniciog1n1.empty? && campoFechaIniciog1n1[0] != nil && cfv_ac.custom_field_id == campoFechaIniciog1n1[0].id && cfv_ac.value != nil && (fechaInicio == nil || fechaInicio > cfv_ac.value)
                @fechaInicio = cfv_ac.value.to_date
              end

              if campoFechaFing1n1 != nil && !campoFechaFing1n1.empty? && campoFechaFing1n1[0] != nil && cfv_ac.custom_field_id == campoFechaFing1n1[0].id && cfv_ac.value != nil && (fechaFin == nil || fechaFin > cfv_ac.value)
                @fechaFin = cfv_ac.value.to_date
              end

              if campoFechaFing1n1 != nil && !campoFechaFing1n1.empty? && campoFechaFing1n1[0] != nil && cfv_ac.custom_field_id == campoFechaFing1n1[0].id && cfv_ac.value != nil && (fechaFin == nil || fechaFin > cfv_ac.value)
                @fechaFin = cfv_ac.value
              end
            end
          end

          otsAux = Issue.where({tracker: tipopeticiong1n2, parent: ac.id, status: estadosOtsg1n2})

          if otsAux != nil && !otsAux.empty?
            otsAux.each do |ot|
              issuesOts.push(ot)
            end
          end

          if issueStatusOtsG1 != nil && !issueStatusOtsG1.empty?
            issueStatusOtsG1.each do |isOts|
              auxs = Array.new

              if !@mapaG1.empty? && @mapaG1[isOts.id] != nil && !@mapaG1[isOts.id].empty?
                auxs << @mapaG1[isOts.id]
              end

              isOtsAux = Issue.where({tracker: tipopeticiong1n2, parent: ac.id, status: isOts})

              if isOtsAux != nil && !isOtsAux.empty?
                auxs << isOtsAux

                @mapaG1[isOts.id] = auxs
              end
            end
          end
        end
      end

      @diasTotales = nil
      @diasTranscurridos = nil
      @porcentajeDiasTranscurridos = nil

      if @fechaFin != nil && @fechaInicio != nil
        @diasTotales = (@fechaFin - @fechaInicio).to_i
      end
      
      if @fechaHoy != nil && @fechaInicio != nil
        @diasTranscurridos = (@fechaHoy - @fechaInicio).to_i
      end

      if @diasTotales != nil && @diasTotales != 0 && @diasTranscurridos != nil && @diasTranscurridos != 0
        @porcentajeDiasTranscurridos = @diasTranscurridos * 100 / @diasTotales
      end

      campoImporte1g1n2 = IssueCustomField.where({id: (importe1g1n2).sub("core__", '').sub("custom__", '')})
      campoImporte2g1n2 = IssueCustomField.where({id: (importe2g1n2).sub("core__", '').sub("custom__", '')})
      campoPorcentajeg1n2 = IssueCustomField.where({id: (porcentajeg1n2).sub("core__", '').sub("custom__", '')})

      @mapaImportes = Hash.new

      @mapaImportes["Disponible"] = importeAC

      @mapaPorcentajesImportes = Hash.new

      @mapaPorcentajesImportes["Disponible"] = 100

      importeEstadoAcumulado = 0

      porcentajeImportesAcumulado = 0

      # Por cada estado agrupado se acumularán los importes
      # Comprobando el importe final y, si no existiese, el importe estimado
      logger.info('Recopilando los datos para montar la gráfica 1')
      if @mapaG1 != nil && !@mapaG1.empty?
        @mapaG1.each do |key, otss|
          importeEstado = 0
          mapaEnCurso = Hash.new
          porcentajeEnCursoRealizado = 0

          if otss != nil && !otss.empty?
            for ots in otss
              if ots != nil && !ots.empty?
                for ot in ots
                  importeEstadoAux = 0
                  valorFinalCore = 0
                  valorEstimadoCore = 0
                  porcentajeRealizadoCore = 0
                  porcentajeRealizado = 0

                  if tracker_fields != nil && !tracker_fields.empty?
                    tracker_fields.each do |field|
                      if ("core__" + field).sub(/_id$/, '') == importe1g1n2
                        valorFinalCore = eval("ot." + (importe1g1n2).sub("core__", ''))
                      end

                      if ("core__" + field).sub(/_id$/, '') == importe2g1n2
                        valorEstimadoCore = eval("ot." + (importe2g1n2).sub("core__", ''))
                      end

                      if issueStatusOtsInProcess != nil && !issueStatusOtsInProcess.empty? && issueStatusOtsInProcess[0] != nil && issueStatusOtsInProcess[0].id == key
                        if ("core__" + field).sub(/_id$/, '') == porcentajeg1n2
                          porcentajeRealizadoCore = eval("ot." + (porcentajeg1n2).sub("core__", ''))
                        end
                      end
                    end
                  end

                  if valorFinalCore == nil || valorFinalCore == 0
                    importeEstadoAux += valorEstimadoCore
                  else
                    importeEstadoAux += valorFinalCore
                  end

                  if porcentajeRealizadoCore != nil
                    porcentajeRealizado = porcentajeRealizadoCore
                  end

                  custom_field_values_ot = ot.custom_field_values

                  if custom_field_values_ot != nil && !custom_field_values_ot.empty?
                    valorFinal = 0
                    valorEstimado = 0
                    porcentajeRealizadoCustom = 0

                    for cfv_ot in custom_field_values_ot
                      if campoImporte1g1n2 != nil && !campoImporte1g1n2.empty? && campoImporte1g1n2[0] != nil && cfv_ot.custom_field_id == campoImporte1g1n2[0].id && cfv_ot.value != nil && cfv_ot.value != 0
                        valorFinal += cfv_ot.value.to_i
                      end

                      if campoImporte2g1n2 != nil && !campoImporte2g1n2.empty? && campoImporte2g1n2[0] != nil && cfv_ot.custom_field_id == campoImporte2g1n2[0].id && cfv_ot.value != nil && cfv_ot.value != 0
                        valorEstimado += cfv_ot.value.to_i
                      end

                      if campoPorcentajeg1n2 != nil && !campoPorcentajeg1n2.empty? && campoPorcentajeg1n2[0] != nil && cfv_ot.custom_field_id == campoPorcentajeg1n2[0].id && cfv_ot.value != nil
                        porcentajeRealizadoCustom += cfv_ot.value.to_i
                      end
                    end

                    if valorFinal == nil || valorFinal == 0
                      importeEstadoAux += valorEstimado
                    else
                      importeEstadoAux += valorFinal
                    end

                    if porcentajeRealizadoCustom != nil && porcentajeRealizadoCustom != 0
                      porcentajeRealizado = porcentajeRealizadoCustom
                    end
                  end

                  importeEstado += importeEstadoAux

                  if issueStatusOtsInProcess != nil && !issueStatusOtsInProcess.empty? && issueStatusOtsInProcess[0] != nil && issueStatusOtsInProcess[0].id == key && importeEstadoAux != nil && porcentajeRealizado != nil
                    mapaEnCurso[ot.id] = importeEstadoAux.to_s + "___" + porcentajeRealizado.to_s
                  end
                end
              end
            end
          end

          if issueStatusOtsInProcess != nil && !issueStatusOtsInProcess.empty? && issueStatusOtsInProcess[0] != nil && issueStatusOtsInProcess[0].id == key
            if importeEstado != nil && importeEstado != 0 && importeAC != nil && importeAC != 0
              importeRealizadoTotal = 0

              if mapaEnCurso != nil && !mapaEnCurso.empty?
                mapaEnCurso.each do |key, strValue|
                  arrValue = strValue.split("___")

                  if arrValue != nil && !arrValue.empty? && arrValue.length == 2
                    importeOTRealizado = arrValue[0].to_i
                    porcentOTRealizado = arrValue[1].to_i

                    if importeOTRealizado != nil && importeOTRealizado != 0 && porcentOTRealizado != nil && porcentOTRealizado != 0
                      importeRealizadoTotal += importeOTRealizado * porcentOTRealizado / 100
                    end
                  end
                end
              end

              if importeRealizadoTotal != nil && importeRealizadoTotal != 0
                @importePonderado = (importeEstado - importeRealizadoTotal) * 100

                @mapaPorcentajesImportes[key] = (((importeEstado - importeRealizadoTotal) * 100).round(1) / (importeAC).round(1)).round(0)

                porcentajeImportesAcumulado += (importeEstado * 100 / importeAC)

                porcentajeEnCursoRealizado = (importeRealizadoTotal * 100 / importeEstado).round(0)

                if porcentajeEnCursoRealizado != nil
                  porcentajeEnCursoRealizadoPonderado = 0
                  porcentajeEnCursoAux = (importeEstado * 100 / importeAC).round(0)

                  if porcentajeEnCursoAux != nil && porcentajeEnCursoAux != 0
                    porcentajeEnCursoRealizadoPonderado = (porcentajeEnCursoRealizado * porcentajeEnCursoAux / 100).round(0)
                  end

                  if porcentajeEnCursoRealizadoPonderado != nil
                    @mapaPorcentajesImportes["En curso-realizado"] = porcentajeEnCursoRealizadoPonderado
                  end
                end

                @mapaImportes[key] = importeEstado

                importeEstadoAcumulado += importeEstado
              else
                @mapaImportes[key] = importeEstado

                importeEstadoAcumulado += importeEstado

                @mapaPorcentajesImportes[key] = (importeEstado * 100 / importeAC)

                porcentajeImportesAcumulado += (importeEstado * 100 / importeAC)
              end
            end
          else
            if importeEstado != nil && importeEstado != 0 && importeAC != nil && importeAC != 0
              @mapaImportes[key] = importeEstado

              importeEstadoAcumulado += importeEstado

              @mapaPorcentajesImportes[key] = (importeEstado * 100 / importeAC)

              porcentajeImportesAcumulado += (importeEstado * 100 / importeAC)
            end
          end

          # importe1 * porcentaje1 / 100 = importeRealizado1
          # importe2 * porcentaje2 / 100 = importeRealizado2
          # importe3 * porcentaje3 / 100 = importeRealizado3
          # ...
          # importeN * porcentajeN / 100 = importeRealizadoN
          #
          # 1 * 100 / 100 = 1
          # 1000 * 50 / 100 = 500
          # 300 * 80 / 100 = 240
          #
          # importeRealizadoTotal = 1 + 500 + 240 = 741
          #
          # importeTotal = 1 + 1000 + 300 = 1301
          #
          # importeRealizadoTotal * 100 / importeTotal
          # 
          # 741 * 100 / 1301 = 56'956187548
        end
      end

      @mapaImportes["Disponible"] = importeAC - importeEstadoAcumulado

      @mapaPorcentajesImportes["Disponible"] = (100 - porcentajeImportesAcumulado).round(0)

      @mapaTablaG1 = Hash.new
      @importeAcumuladoG1 = 0
      @porcentajeAcumuladoG1 = 0

      if @mapaImportes != nil && !@mapaImportes.empty?
        @mapaImportes.to_a.reverse.to_h.each do |key, value|
          porcentajeG1 = 0
          arrayAux = Array.new

          if key != nil && key == "Disponible"
            arrayAux.push("Disponible")
          else
            if issueStatusOtsInProcess != nil && !issueStatusOtsInProcess.empty? && issueStatusOtsInProcess[0] != nil && issueStatusOtsInProcess[0].id == key && @mapaPorcentajesImportes["En curso-realizado"] != nil
              porcentajeG1 += @mapaPorcentajesImportes["En curso-realizado"]
            end

            isSt = IssueStatus.where({id: key})

            if isSt != nil && !isSt.empty?
              arrayAux.push(isSt[0].to_s)
            end
          end

          porcentajeG1 += @mapaPorcentajesImportes[key]

          @porcentajeAcumuladoG1 += porcentajeG1

          @importeAcumuladoG1 += @mapaImportes[key]

          arrayAux.push(@mapaImportes[key])

          arrayAux.push(porcentajeG1)

          arrayAux.push(@porcentajeAcumuladoG1)

          @mapaTablaG1[key] = arrayAux
        end
      end

      colorFacturado = "#3465A4"
      colorCerrado = "#0066CC"
      colorResuelto = "#729FCF"
      colorEnCurso = "#83CAFF"
      colorDisponible = "#AEA79F"
      colorEnCursoRealizado = "#819BAF"

      colores = Array.new

      colores.push(colorEnCurso)
      colores.push(colorResuelto)
      colores.push(colorCerrado)
      colores.push(colorFacturado)

      logger.info('Se inicializa stackG1a')
      @stackG1a = LazyHighCharts::HighChart.new('stackG1a') do |f|
        pointWidth = 60
        if procedencia == 'indicadores'
          f.chart({defaultSeriesType: "bar", height: 175, width: 700})
          f.legend(align: 'right', verticalAlign: 'top', y: 30, x: -50, layout: 'vertical')
          f.tooltip(false)
        else
          f.chart({defaultSeriesType: "bar", height: 100})
          f.legend(false)
          f.tooltip(useHTML: true, headerFormat: '<small>{point.key}</small><table>', pointFormat: '<tr><td style="color: {series.color}">{series.name}: </td>' + '<td style="text-align: right"><b>{point.y} %</b></td></tr>', footerFormat: '</table>')
        end
        f.exporting(false)
        f.title(text: I18n.t('title_g1'))
        f.xAxis(categories: [""])
        f.plot_options({bar: {stacking: "percent", dataLabels: {format: "{y}%", enabled: true, style: {color: "#FFFFFF", fontWeight: "bold"}}}})

        plotLines = Array.new

        if @mapaPorcentajesImportes != nil && !@mapaPorcentajesImportes.empty?
          cont = 0
          @mapaPorcentajesImportes.each do |key, porcentajeEstado|
            if key != nil && key == "Disponible"
              f.series(name: I18n.t('field_available'), data: [(porcentajeEstado).round(0)], color: colorDisponible, pointWidth: pointWidth)
            elsif key != nil && key == "En curso-realizado"
              f.series(name: I18n.t('field_completed'), data: [(porcentajeEstado).round(0)], color: colorEnCursoRealizado, pointWidth: pointWidth)
            else
              isSt = IssueStatus.where({id: key})

              if isSt != nil && !isSt.empty?
                if cont < 4
                  f.series(name: I18n.t("field_" + isSt[0].to_s), data: [(porcentajeEstado).round(0)], color: colores[cont], pointWidth: pointWidth)
                else
                  f.series(name: I18n.t("field_" + isSt[0].to_s), data: [(porcentajeEstado).round(0)], pointWidth: pointWidth)
                end
              end

              cont += 1
            end
          end
        else
          f.series(name: I18n.t('field_available'), data: [100], color: colorDisponible, pointWidth: pointWidth)
        end
      end

      logger.info('Se inicializa stackG1b')
      @stackG1b = LazyHighCharts::HighChart.new('stackG1b') do |f|
        pointWidth = 15
        if procedencia == 'indicadores'
          f.chart({defaultSeriesType: "bar", height: 100, width: 533})
        else
          f.chart({defaultSeriesType: "bar", height: 85})
        end
        f.legend(false)
        f.tooltip(false)
        f.exporting(false)
        f.title(text: I18n.t('title_g1b'))
        f.xAxis(categories: [""])
        f.plot_options({bar: {stacking: "percent", dataLabels: {format: "{percentage}%", enabled: true, style: {color: "#FFFFFF", fontWeight: "bold"}}, grouping: false, shadow: false, borderWidth: 0, borderColor: "grey"}})

        if @porcentajeDiasTranscurridos != nil
          f.series(name: I18n.t('field_available'), data: [100 - @porcentajeDiasTranscurridos], color: "grey", pointWidth: pointWidth)
          f.series(name: I18n.t('field_passed'), data: [@porcentajeDiasTranscurridos], color: "black", pointWidth: pointWidth)
        end
      end

      ### ************************************************************************************ ###
      ### ************************************************************************************ ###
      ### ************************************************************************************ ###
      ### ************************************************************************************ ###
      ### ************************************************************************************ ###
      ### ************************************************************************************ ###

      tipopeticiong2n1 = ""
      tipopeticiong2n2 = ""
      issuesOtsG2 = Array.new
      issueStatusOtsG2 = Array.new

      # Se reciben los parametros de la configuracion
      # y se prepara la grafica de importes ejecutados por año

      tipospeticiong2n1 = Tracker.where({id: @settings['tipo_peticion_g2n1']})
      tipospeticiong2n2 = Tracker.where({id: @settings['tipo_peticion_g2n2']})
      estadosAcsg2n1 = @settings['estado_g2n1']
      estadosOtsg2n2 = @settings['estado_g2n2']
      importe1g2n2 = @settings['importe1_g2n2']
      importe2g2n2 = @settings['importe2_g2n2']
      fechaFing2n2 = @settings['fecha_fin_g2n2']


      if tipospeticiong2n1 != nil && !tipospeticiong2n1.empty?
        tipopeticiong2n1 = tipospeticiong2n1[0]
      end

      if tipospeticiong2n2 != nil && !tipospeticiong2n2.empty?
        tipopeticiong2n2 = tipospeticiong2n2[0]
      end

      if estadosOtsg2n2 != nil && !estadosOtsg2n2.empty?
        issueStatusOtsG2 = IssueStatus.where({id: estadosOtsg2n2})
      end

      campoImporte1g2n2 = IssueCustomField.where({id: (importe1g2n2).sub("core__", '').sub("custom__", '')})
      campoImporte2g2n2 = IssueCustomField.where({id: (importe2g2n2).sub("core__", '').sub("custom__", '')})
      campoFechaFing2n2 = IssueCustomField.where({id: (fechaFing2n2).sub("core__", '').sub("custom__", '')})

      @mapaG2 = Hash.new
      
      # Se obtienen las AC con el estado indicado
      logger.info('Se obtienen las AC con el estado indicado (G2)')
      @acsG2 = Issue.where({project: whereProject, tracker: tipopeticiong2n1, status: estadosAcsg2n1})

      @fechaInicioG2 = nil
      @fechaFinG2 = nil

      if @acsG2 == nil || @acsG2.empty?
        # Si no hay AC se obtendrán directamente las OT del contenedor
        logger.info('No se encontraron ACs (G2))')
        issuesOtsG2 = Issue.where({project: whereProject, tracker: tipopeticiong2n2, status: estadosOtsg2n2})
      else
        logger.info('Se encontraron ACs, se continúa con los cálculos (G2))')
        # Por cada AC se obtendrán sus OT
        logger.info('Por cada AC se obtendrán las OT (G2)')
        @acsG2.each do |ac|
          otsAux = Issue.where({tracker: tipopeticiong2n2, parent: ac.id, status: estadosOtsg2n2})

          if otsAux != nil && !otsAux.empty?
            otsAux.each do |ot|
              issuesOtsG2.push(ot)
            end
          end
        end
      end

      if issuesOtsG2 != nil && !issuesOtsG2.empty?
        issuesOtsG2.each do |ot|
          anyo = 0
          importe = 0

          valorFinalCore = nil
          valorEstimadoCore = nil
          fechaFinCore = nil

          if tracker_fields != nil && !tracker_fields.empty?
            tracker_fields.each do |field|
              if ("core__" + field).sub(/_id$/, '') == importe1g2n2
                valorFinalCore = eval("ot." + (importe1g2n2).sub("core__", ''))
              end

              if ("core__" + field).sub(/_id$/, '') == importe2g2n2
                valorEstimadoCore = eval("ot." + (importe2g2n2).sub("core__", ''))
              end

              if ("core__" + field).sub(/_id$/, '') == fechaFing2n2
                fechaFinCore = eval("ot." + (fechaFing2n2).sub("core__", ''))
              end
            end
          end

          if valorFinalCore == nil || valorFinalCore == 0
            if valorEstimadoCore != nil && valorEstimadoCore != 0
              importe = valorEstimadoCore
            end
          else
            importe = valorFinalCore
          end

          if fechaFinCore != nil
            anyo = (fechaFinCore).strftime("%Y")
          end

          custom_field_values_ot = ot.custom_field_values

          if custom_field_values_ot != nil && !custom_field_values_ot.empty?
            for cfv_ot in custom_field_values_ot
              if campoImporte1g2n2 != nil && !campoImporte1g2n2.empty? && campoImporte1g2n2[0] != nil && cfv_ot.custom_field_id == campoImporte1g2n2[0].id && cfv_ot.value != nil && cfv_ot.value != 0
                valorFinalCustom = cfv_ot.value.to_i
              end

              if campoImporte2g2n2 != nil && !campoImporte2g2n2.empty? && campoImporte2g2n2[0] != nil && cfv_ot.custom_field_id == campoImporte2g2n2[0].id && cfv_ot.value != nil && cfv_ot.value != 0
                valorEstimadoCustom = cfv_ot.value.to_i
              end

              if campoFechaFing2n2 != nil && !campoFechaFing2n2.empty? && campoFechaFing2n2[0] != nil && cfv_ac.custom_field_id == campoFechaFing2n2[0].id && cfv_ot.value != nil && (anyo == nil || anyo == 0)
                anyo = (cfv_ot.value).strftime("%Y")
              end
            end

            if valorFinalCustom == nil || valorFinalCustom == 0
              if valorEstimadoCustom != nil && valorEstimadoCustom != 0
                importe = valorEstimadoCustom
              end
            else
              importe = valorFinalCustom
            end
          end

          if @mapaG2 != nil && anyo != 0
            if @mapaG2[anyo] == nil
              if importe != 0
                @mapaG2[anyo] = importe
              end
            else
              importe += @mapaG2[anyo]
              @mapaG2[anyo] = importe
            end
          end
        end
      end

      if @mapaG2 != nil
        # Se ordena el mapa por key para que salga ordenado cronológicamente
        @mapaG2 = @mapaG2.sort.to_h
      end

      logger.info('Se inicializa chartG2')
      @chartG2 = LazyHighCharts::HighChart.new('chartG2') do |f|
        if procedencia == 'indicadores'
          f.chart({defaultSeriesType: "column", width: 700})
        else
          f.chart({defaultSeriesType: "column", height: 200})
        end
        f.legend(false)
        f.tooltip(false)
        f.exporting(false)
        f.title(text: I18n.t('title_g2'))
        f.xAxis(categories: @mapaG2.keys)

        arrayData = Array.new

        @mapaG2.each do |key, importe|
          arrayMap = Array.new
          arrayMap.push(key)
          arrayMap.push(importe)
          arrayData.push(arrayMap)
        end

        f.series(name: "Presupuesto", data: arrayData, pointWidth: 40)
      end
    end
  end
end

IndicadoresController.send(:include, TeoManagementIndicatorsUtilities::InstanceMethods)