# Se importan las clases de utilidad
require 'charts/printers/actuaciones_en_curso'
require 'charts/printers/tiempo_transcurrido'

module Charts
  class GraficaActuacionesEnCurso

    # Método que calcula los datos para cargar la primera gráfica
    def self.calculaGraficaActuacionesEnCurso(whereProject, tracker_fields, settings, chart_view)
      Rails.logger.info('Dentro de calculaGraficaActuacionesEnCurso.')

      tipopeticiong1n1 = ""
      tipopeticiong1n2 = ""
      issueStatusOtsG1 = Array.new
      isOtsAux = Array.new
      issueStatusOtsInProcess = Array.new
      tipopeticiong1n1issues = ""

      issueCustomField = IssueCustomField.where('name = \'Contrato\'')[0]
      $ID_CONST_CUSTFIELD = issueCustomField.id

      # Se reciben los parametros de la configuracion
      # y se prepara la grafica de estado de actuaciones "en curso"
      Rails.logger.info('Se reciben los parametros de la configuracion y se prepara la grafica de estado de actuaciones "en curso"')
      if !settings.tipospeticiong1n1.nil? && settings.tipospeticiong1n1.any?
        tipopeticiong1n1 = settings.tipospeticiong1n1[0]
      end

      if !settings.tipospeticiong1n2.nil? && settings.tipospeticiong1n2.any?
        tipopeticiong1n2 = settings.tipospeticiong1n2[0]
      end

      if !settings.estadosOtsg1n2.nil? && settings.estadosOtsg1n2.any?
        issueStatusOtsG1 = IssueStatus.where({id: settings.estadosOtsg1n2})
      end

      if !issueStatusOtsG1.nil? && issueStatusOtsG1.any?
        issueStatusOtsG1 = issueStatusOtsG1.order(:position)
        isOtsAux = Issue.where({tracker: tipopeticiong1n2, status: issueStatusOtsG1})
      end

      if !settings.estadosEncursoOtsg1n2.nil?
        issueStatusOtsInProcess = IssueStatus.where({id: settings.estadosEncursoOtsg1n2})
      end

      if !settings.tipospeticiong1n1issues.nil? && settings.tipospeticiong1n1issues.any?
        tipopeticiong1n1issues = settings.tipospeticiong1n1issues[0]
      end

      mapaG1 = Hash.new
      acsG1 = nil
      # Se obtienen las AC con el estado indicado
      Rails.logger.info('Se obtienen las AC con el estado indicado (G1)')
      acsG1 = Issue.where({project: whereProject, tracker: tipopeticiong1n1, status: settings.estadosAcsg1n1})
     

      importeAC = 0
      fechaInicio = nil
      fechaFin = nil
      if acsG1.nil? || !acsG1.any?
        Rails.logger.info('No se encontraron ACs (G1))')
      else
        Rails.logger.info('Se encontraron ACs, se continúa con los cálculos (G1))')

        campoImporteg1n1 = nil
        campoFechaIniciog1n1 = nil
        campoFechaFing1n1 = nil

        if !settings.importeg1n1.nil?
          campoImporteg1n1 = IssueCustomField.where({id: (settings.importeg1n1).sub("core__", '').sub("custom__", '')})

          if campoImporteg1n1 != nil && !campoImporteg1n1.empty? && campoImporteg1n1[0] != nil && campoImporteg1n1[0].field_format != nil && campoImporteg1n1[0].field_format.to_s != nil && campoImporteg1n1[0].field_format.to_s != '' && campoImporteg1n1[0].field_format.to_s != 'float'
            Rails.logger.warn('Se ha elegido un campo no válido como importe (' + campoImporteg1n1[0].field_format.to_s + ').')
            campoImporteg1n1 = nil
          end
        end
        if !settings.fechaIniciog1n1.nil?
          campoFechaIniciog1n1 = IssueCustomField.where({id: (settings.fechaIniciog1n1).sub("core__", '').sub("custom__", '')})

          if campoFechaIniciog1n1 != nil && !campoFechaIniciog1n1.empty? && campoFechaIniciog1n1[0] != nil && campoFechaIniciog1n1[0].field_format != nil && campoFechaIniciog1n1[0].field_format.to_s != nil && campoFechaIniciog1n1[0].field_format.to_s != '' && campoFechaIniciog1n1[0].field_format.to_s != 'date'
            Rails.logger.warn('Se ha elegido un campo no válido como fecha (' + campoFechaIniciog1n1[0].field_format.to_s + ').')
            campoFechaIniciog1n1 = nil
          end
        end
        if !settings.fechaFing1n1.nil?
          campoFechaFing1n1 = IssueCustomField.where({id: (settings.fechaFing1n1).sub("core__", '').sub("custom__", '')})

          if campoFechaFing1n1 != nil && !campoFechaFing1n1.empty? && campoFechaFing1n1[0] != nil && campoFechaFing1n1[0].field_format != nil && campoFechaFing1n1[0].field_format.to_s != nil && campoFechaFing1n1[0].field_format.to_s != '' && campoFechaFing1n1[0].field_format.to_s != 'date'
            Rails.logger.warn('Se ha elegido un campo no válido como fecha (' + campoFechaFing1n1[0].field_format.to_s + ').')
            campoFechaFing1n1 = nil
          end
        end

        # Por cada AC se obtendrán las OT y se agruparán por su estado
        Rails.logger.info('Por cada AC se obtendrán las OT y se agruparán por su estado (G1)')
        acsG1.each do |ac|
          
          issue_fields = obtenerValorCamposImporteYFechasAC(settings, tracker_fields, ac, campoImporteg1n1, campoFechaIniciog1n1, campoFechaFing1n1, importeAC, fechaInicio, fechaFin)

          importeAC = issue_fields.importeAC
          fechaInicio = issue_fields.fechaInicio
          fechaFin = issue_fields.fechaFin

          if !issueStatusOtsG1.nil? && issueStatusOtsG1.any?
            issueStatusOtsG1.each do |isOts|
              
              auxs = Array.new
              if mapaG1.any? && !mapaG1[isOts.id].nil? && mapaG1[isOts.id].any?
                arrayMapaG1Aux = Array.new
                arrayMapaG1Aux = mapaG1[isOts.id]

                for elementoMapaG1Aux in arrayMapaG1Aux
                  auxs.push(elementoMapaG1Aux)
                end
              end

              if !isOtsAux.nil? && isOtsAux.any?
                for elementoIsOtsAux in isOtsAux
                  if !elementoIsOtsAux.parent_id.nil? && elementoIsOtsAux.parent_id == ac.id && elementoIsOtsAux.status_id == isOts.id
                    auxs.push(elementoIsOtsAux)
                  end
                end

                mapaG1[isOts.id] = auxs
              end
            end
          end
        end
      end

      campoImporte1g1n2 = nil
      campoImporte2g1n2 = nil
      campoPorcentajeg1n2 = nil

      if !settings.importe1g1n2.nil?
        campoImporte1g1n2 = IssueCustomField.where({id: (settings.importe1g1n2).sub("core__", '').sub("custom__", '')})

        if campoImporte1g1n2 != nil && !campoImporte1g1n2.empty? && campoImporte1g1n2[0] != nil && campoImporte1g1n2[0].field_format != nil && campoImporte1g1n2[0].field_format.to_s != nil && campoImporte1g1n2[0].field_format.to_s != '' && campoImporte1g1n2[0].field_format.to_s != 'float'
          Rails.logger.warn('Se ha elegido un campo no válido como importe (' + campoImporte1g1n2[0].field_format.to_s + ').')
          campoImporte1g1n2 = nil
        end
      end
      if !settings.importe2g1n2.nil?
        campoImporte2g1n2 = IssueCustomField.where({id: (settings.importe2g1n2).sub("core__", '').sub("custom__", '')})

        if campoImporte2g1n2 != nil && !campoImporte2g1n2.empty? && campoImporte2g1n2[0] != nil && campoImporte2g1n2[0].field_format != nil && campoImporte2g1n2[0].field_format.to_s != nil && campoImporte2g1n2[0].field_format.to_s != '' && campoImporte2g1n2[0].field_format.to_s != 'float'
          Rails.logger.warn('Se ha elegido un campo no válido como importe (' + campoImporte2g1n2[0].field_format.to_s + ').')
          campoImporte2g1n2 = nil
        end
      end
      if !settings.porcentajeg1n2.nil?
        campoPorcentajeg1n2 = IssueCustomField.where({id: (settings.porcentajeg1n2).sub("core__", '').sub("custom__", '')})
      end

      mapaImportes = Hash.new
      mapaImportes["Disponible"] = importeAC
      importeEstadoAcumulado = 0

      mapaPorcentajesImportes = Hash.new
      mapaPorcentajesImportes["Disponible"] = 100
      porcentajeImportesAcumulado = 0

      # Por cada estado agrupado se acumularán los importes
      # Comprobando el importe final y, si no existiese, el importe estimado
      Rails.logger.info('Recopilando los datos para montar la gráfica 1')
      mapaG1LinksProy = Hash.new
      
      if mapaG1 != nil && !mapaG1.empty?
        mapaG1.each do |key, ots|
          
          s = '%7C'
          mapaG1LinksProy[key]

          importeEstado = 0
          mapaEnCurso = Hash.new
          porcentajeEnCursoRealizado = 0

          if ots != nil && !ots.empty?
            for ot in ots
              issue_fields = obtenerValorCamposImporteYPorcentajeOT(settings, tracker_fields, ot, issueCustomField, issueStatusOtsInProcess, campoImporte1g1n2, campoImporte2g1n2, campoPorcentajeg1n2)

              importeEstadoAux = issue_fields.importeEstado
              porcentajeRealizado = issue_fields.porcentajeRealizado

              importeEstado += importeEstadoAux

              if issueStatusOtsInProcess != nil && !issueStatusOtsInProcess.empty? && issueStatusOtsInProcess[0] != nil && issueStatusOtsInProcess[0].id == key && importeEstadoAux != nil && porcentajeRealizado != nil
                mapaEnCurso[ot.id] = importeEstadoAux.to_s + "___" + porcentajeRealizado.to_s
              end

              llave = ot.status.name + $SPLIT_CHAR + ot.status.id.to_s
              if mapaG1LinksProy[llave] != nil
                mapaG1LinksProy[llave] = mapaG1LinksProy[llave] + '%7C' + issue_fields.idenf_proy.to_s
              else
                mapaG1LinksProy[llave] = issue_fields.idenf_proy.to_s
              end
            end
          end

          # Se anula la división entre en curso y completado
          issueStatusOtsInProcess = nil
          # Eliminar asignación nil si se volviera a recuperar

          if !issueStatusOtsInProcess.nil? && issueStatusOtsInProcess.any? && !issueStatusOtsInProcess[0].nil? && issueStatusOtsInProcess[0].id == key
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
                mapaPorcentajesImportes[key] = (((importeEstado - importeRealizadoTotal) * 100).round(1) / (importeAC).round(1)).round(0)

                porcentajeImportesAcumulado += (importeEstado * 100 / importeAC)

                porcentajeEnCursoRealizado = (importeRealizadoTotal * 100 / importeEstado).round(0)

                if porcentajeEnCursoRealizado != nil
                  porcentajeEnCursoRealizadoPonderado = 0
                  porcentajeEnCursoAux = (importeEstado * 100 / importeAC).round(0)

                  if porcentajeEnCursoAux != nil && porcentajeEnCursoAux != 0
                    porcentajeEnCursoRealizadoPonderado = (porcentajeEnCursoRealizado * porcentajeEnCursoAux / 100).round(0)
                  end

                  if porcentajeEnCursoRealizadoPonderado != nil
                    mapaPorcentajesImportes["En curso-realizado"] = porcentajeEnCursoRealizadoPonderado
                  end
                end

                mapaImportes[key] = importeEstado

                importeEstadoAcumulado += importeEstado
              else
                mapaImportes[key] = importeEstado

                importeEstadoAcumulado += importeEstado

                mapaPorcentajesImportes[key] = (importeEstado * 100 / importeAC)

                porcentajeImportesAcumulado += (importeEstado * 100 / importeAC)
              end
            end
          else
            if importeEstado != nil && importeEstado != 0 && importeAC != nil && importeAC != 0
              mapaImportes[key] = importeEstado

              importeEstadoAcumulado += importeEstado

              mapaPorcentajesImportes[key] = (importeEstado * 100 / importeAC)

              porcentajeImportesAcumulado += (importeEstado * 100 / importeAC)
            end
          end
        end
      end

      mapaImportes["Disponible"] = importeAC - importeEstadoAcumulado

      mapaPorcentajesImportes["Disponible"] = (100 - porcentajeImportesAcumulado).round(0)

      mapaTablaG1 = Hash.new
      importeAcumuladoG1 = 0
      porcentajeAcumuladoG1 = 0

      if mapaImportes != nil && !mapaImportes.empty?
        mapaImportes.to_a.reverse.to_h.each do |key, value|
          porcentajeG1 = 0
          arrayAux = Array.new

          if key != nil && key == "Disponible"
            arrayAux.push("Disponible")
          else
            if issueStatusOtsInProcess != nil && !issueStatusOtsInProcess.empty? && issueStatusOtsInProcess[0] != nil && issueStatusOtsInProcess[0].id == key && mapaPorcentajesImportes["En curso-realizado"] != nil
              porcentajeG1 += mapaPorcentajesImportes["En curso-realizado"]
            end

            isSt = IssueStatus.where({id: key})

            if isSt != nil && !isSt.empty?
              arrayAux.push(isSt[0].to_s)
            end
          end

          porcentajeG1 += mapaPorcentajesImportes[key]

          porcentajeAcumuladoG1 += porcentajeG1

          importeAcumuladoG1 += mapaImportes[key]

          arrayAux.push(mapaImportes[key])

          arrayAux.push(porcentajeG1)

          arrayAux.push(porcentajeAcumuladoG1)

          mapaTablaG1[key] = arrayAux
        end
      end

      chart_view.set_acsG1(acsG1)
      chart_view.set_fechaInicio(fechaInicio)
      chart_view.set_fechaFin(fechaFin)
      chart_view.set_fechaHoy(Date.today)
      chart_view.set_mapaTablaG1(mapaTablaG1)
      chart_view.set_importeAcumuladoG1(importeAcumuladoG1)
      chart_view.set_porcentajeAcumuladoG1(porcentajeAcumuladoG1)
      chart_view.set_mapaG1LinksProy(mapaG1LinksProy)
      
      linkActivado = settings.actLinkg2 != nil && settings.actLinkg2 == "true"
      Printers::ActuacionesEnCurso.pintarActuacionesEnCurso(chart_view, mapaPorcentajesImportes, linkActivado)
      Printers::TiempoTranscurrido.pintarTiempoTranscurrido(chart_view)
    end

    # Método que obtiene de la AC dada el valor de los campos de importe y fechas
    def self.obtenerValorCamposImporteYFechasAC(settings, tracker_fields, ac, campoImporteg1n1, campoFechaIniciog1n1, campoFechaFing1n1, importeAC, fechaInicio, fechaFin)
      Rails.logger.debug('Dentro de obtenerValorCamposImporteYFechasAC.')
      importeACCore = nil
      fechaInicioCore = nil
      fechaFinCore = nil

      if tracker_fields != nil && !tracker_fields.empty?
        tracker_fields.each do |field|
          if Issue.columns_hash[field].to_s != nil && Issue.columns_hash[field].to_s != '' && Issue.columns_hash[field].type != nil && Issue.columns_hash[field.to_s].type.to_s != nil && Issue.columns_hash[field.to_s].type.to_s != ''
            if ("core__" + field).sub(/_id$/, '') == settings.importeg1n1
              if Issue.columns_hash[field.to_s].type.to_s == 'float'
                importeACCore = eval("ac." + (settings.importeg1n1).sub("core__", ''))
              else
                Rails.logger.warn('Se ha elegido un campo no válido como importe (' + Issue.columns_hash[field.to_s].type.to_s + ').')
              end
            end

            if ("core__" + field).sub(/_id$/, '') == settings.fechaIniciog1n1
              if Issue.columns_hash[field.to_s].type.to_s == 'date'
                fechaInicioCore = eval("ac." + (settings.fechaIniciog1n1).sub("core__", ''))
              else
                Rails.logger.warn('Se ha elegido un campo no válido como fecha (' + Issue.columns_hash[field.to_s].type.to_s + ').')
              end
            end

            if ("core__" + field).sub(/_id$/, '') == settings.fechaFing1n1
              if Issue.columns_hash[field.to_s].type.to_s == 'date'
                fechaFinCore = eval("ac." + (settings.fechaFing1n1).sub("core__", ''))
              else
                Rails.logger.warn('Se ha elegido un campo no válido como fecha (' + Issue.columns_hash[field.to_s].type.to_s + ').')
              end
            end
          end
        end
      end

      if importeACCore != nil
        importeAC = importeACCore
      end

      if fechaInicioCore != nil && (fechaInicio == nil || fechaInicio > fechaInicioCore)
        fechaInicio = fechaInicioCore
      end

      if fechaFinCore != nil && (fechaFin == nil || fechaFin < fechaFinCore)
        fechaFin = fechaFinCore
      end

      # Se obtiene el importe que se usará como referencia para calcular los porcentajes por estado
      Rails.logger.info('Se obtiene el importe que se usará como referencia para calcular los porcentajes por estado')
      custom_field_values_ac = ac.custom_field_values

      if custom_field_values_ac != nil && !custom_field_values_ac.empty?
        for cfv_ac in custom_field_values_ac
          if campoImporteg1n1 != nil && !campoImporteg1n1.empty? && campoImporteg1n1[0] != nil && cfv_ac.custom_field_id == campoImporteg1n1[0].id && cfv_ac.value != nil && cfv_ac.value.to_i != 0
            importeAC += cfv_ac.value.to_i
          end

          if campoFechaIniciog1n1 != nil && !campoFechaIniciog1n1.empty? && campoFechaIniciog1n1[0] != nil && cfv_ac.custom_field_id == campoFechaIniciog1n1[0].id && cfv_ac.value != nil && (fechaInicio == nil || fechaInicio > cfv_ac.value.to_date)
            fechaInicio = cfv_ac.value.to_date
          end

          if campoFechaFing1n1 != nil && !campoFechaFing1n1.empty? && campoFechaFing1n1[0] != nil && cfv_ac.custom_field_id == campoFechaFing1n1[0].id && cfv_ac.value != nil && !cfv_ac.value.empty? && (fechaFin == nil || fechaFin < cfv_ac.value.to_date)
            fechaFin = cfv_ac.value.to_date
          end
        end
      end

      issue_fields = IndicatorsUtils::IssueFields.new
      issue_fields.set_importeAC(importeAC)
      issue_fields.set_fechaInicio(fechaInicio)
      issue_fields.set_fechaFin(fechaFin)

      return issue_fields
    end

    # Método que obtiene de la OT dada el valor de los campos de importe y porcentaje
    def self.obtenerValorCamposImporteYPorcentajeOT(settings, tracker_fields, ot, issueCustomField, issueStatusOtsInProcess, campoImporte1g1n2, campoImporte2g1n2, campoPorcentajeg1n2)
      Rails.logger.debug('Dentro de obtenerValorCamposImporteYPorcentajeOT.')
      importeEstadoAux = 0
      valorFinalCore = 0
      valorEstimadoCore = 0
      porcentajeRealizadoCore = 0
      porcentajeRealizado = 0

      if tracker_fields != nil && !tracker_fields.empty?
        tracker_fields.each do |field|
          if Issue.columns_hash[field].to_s != nil && Issue.columns_hash[field].to_s != '' && Issue.columns_hash[field].type != nil && Issue.columns_hash[field.to_s].type.to_s != nil && Issue.columns_hash[field.to_s].type.to_s != ''
            if ("core__" + field).sub(/_id$/, '') == settings.importe1g1n2
              if Issue.columns_hash[field.to_s].type.to_s == 'float'
                valorFinalCore = eval("ot." + (settings.importe1g1n2).sub("core__", ''))
              else
                Rails.logger.warn('Se ha elegido un campo no válido como importe (' + Issue.columns_hash[field.to_s].type.to_s + ').')
              end
            end

            if ("core__" + field).sub(/_id$/, '') == settings.importe2g1n2
              if Issue.columns_hash[field.to_s].type.to_s == 'float'
                valorEstimadoCore = eval("ot." + (settings.importe2g1n2).sub("core__", ''))
              else
                Rails.logger.warn('Se ha elegido un campo no válido como importe (' + Issue.columns_hash[field.to_s].type.to_s + ').')
              end
            end

            if issueStatusOtsInProcess != nil && !issueStatusOtsInProcess.empty? && issueStatusOtsInProcess[0] != nil && issueStatusOtsInProcess[0].id == key
              if ("core__" + field).sub(/_id$/, '') == settings.porcentajeg1n2
                porcentajeRealizadoCore = eval("ot." + (settings.porcentajeg1n2).sub("core__", ''))
              end
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
          if campoImporte1g1n2 != nil && !campoImporte1g1n2.empty? && campoImporte1g1n2[0] != nil && cfv_ot.custom_field_id == campoImporte1g1n2[0].id && cfv_ot.value != nil && cfv_ot.value.to_i != 0
            valorFinal += cfv_ot.value.to_i
          end

          if campoImporte2g1n2 != nil && !campoImporte2g1n2.empty? && campoImporte2g1n2[0] != nil && cfv_ot.custom_field_id == campoImporte2g1n2[0].id && cfv_ot.value != nil && cfv_ot.value.to_i != 0
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

      issue_fields = IndicatorsUtils::IssueFields.new
      issue_fields.set_importeEstado(importeEstadoAux)
      issue_fields.set_porcentajeRealizado(porcentajeRealizado)

      if issueCustomField != nil
        projectId = ot.custom_field_value(issueCustomField.id)
        if projectId != nil && !projectId.empty?
          project = Project.where('id = ' + projectId)[0]
          if project != nil
            issue_fields.set_nombre_proy(project.name)
            issue_fields.set_idenf_proy(project.id)
          end
        end
      end

      return issue_fields
    end
  end
end