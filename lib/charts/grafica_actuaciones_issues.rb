# Se importan las clases de utilidad
require 'charts/printers/actuaciones_issues'

module Charts
  class GraficaActuacionesIssues

    # Método que calcula los datos para cargar la primera gráfica
    def self.calculaGraficaActuacionesIssues(whereProject, tracker_fields, settings, chart_view, id_issue)
      Rails.logger.info('Dentro de calculaGraficaActuacionesIssues.')
      estadoIssues = IssueStatus.all
      tipopeticiong1n1issues = ""
      campoImporte1g2n2 = nil
      campoImporte2g2n2 = nil
      cienPorcien = 100

      # Se reciben los parametros de la configuracion
      # y se prepara la grafica de estado de actuaciones "en curso"
      Rails.logger.info('Se reciben los parametros de la configuracion y se prepara la grafica de estado de actuaciones "en curso"')
      if !settings.tipospeticiong1n1issues.nil? && settings.tipospeticiong1n1issues.any?
        tipopeticiong1n1issues = settings.tipospeticiong1n1issues[0]
      end
      if !settings.importe1g2n2.nil?
        campoImporte1g2n2 = IssueCustomField.where({id: (settings.importe1g2n2).sub("core__", '').sub("custom__", '')})

        if campoImporte1g2n2 != nil && !campoImporte1g2n2.empty? && campoImporte1g2n2[0] != nil && campoImporte1g2n2[0].field_format != nil && campoImporte1g2n2[0].field_format.to_s != nil && campoImporte1g2n2[0].field_format.to_s != '' && campoImporte1g2n2[0].field_format.to_s != 'float'
          Rails.logger.warn('Se ha elegido un campo no válido como importe (' + campoImporte1g2n2[0].field_format.to_s + ').')
          campoImporte1g2n2 = nil
        end
      end
      if !settings.importe2g2n2.nil?
        campoImporte2g2n2 = IssueCustomField.where({id: (settings.importe2g2n2).sub("core__", '').sub("custom__", '')})

        if campoImporte2g2n2 != nil && !campoImporte2g2n2.empty? && campoImporte2g2n2[0] != nil && campoImporte2g2n2[0].field_format != nil && campoImporte2g2n2[0].field_format.to_s != nil && campoImporte2g2n2[0].field_format.to_s != '' && campoImporte2g2n2[0].field_format.to_s != 'float'
          Rails.logger.warn('Se ha elegido un campo no válido como importe (' + campoImporte2g2n2[0].field_format.to_s + ').')
          campoImporte2g2n2 = nil
        end
      end

      mapaG1 = Hash.new
      acsG1 = Issue.where({tracker: tipopeticiong1n1issues, id: id_issue})
      acsG1HijasOt = Issue.where({parent_id: id_issue})      
      listaFieldsLinks = Hash.new

      if (acsG1.nil? || !acsG1.any?) && (acsG1HijasOt.nil? || !acsG1HijasOt.any?)
        Rails.logger.info('No se encontraron ACs (G1) o hijas)')
      else
        Rails.logger.info('Se encontraron ACs, se continúa con los cálculos (G1))')
        totalImporteOts = 0
 
        acsG1HijasOt.each do |ot|
          issue_fields = obtenerValorCamposImporteOT(settings, tracker_fields, ot, campoImporte1g2n2, campoImporte2g2n2)

          if mapaG1.any? && !mapaG1[ot.status.name].nil?
            if issue_fields.importeEjecutado != nil
              mapaG1[ot.status.name] = mapaG1[ot.status.name] + issue_fields.importeEjecutado
            end
          else 
            if issue_fields.importeEjecutado != nil
              mapaG1[ot.status.name] = issue_fields.importeEjecutado
            end
            listaFieldsLinks[ot.status.name] = id_issue.to_s + $SPLIT_CHAR + ot.status.id.to_s
          end

          if issue_fields.importeEjecutado != nil
            totalImporteOts = totalImporteOts + issue_fields.importeEjecutado
          end
        end

        issue_field_ac = obtenerValorCamposImporteAC(settings, tracker_fields, acsG1[0], campoImporte1g2n2, campoImporte2g2n2)

        totalImporte = 0
        importeDisponible = 0

        if totalImporteOts != nil
          totalImporte = totalImporteOts
          chart_view.set_mensajeAC("a los importes de las OTs")
        end

        if issue_field_ac.importeEstado != nil && issue_field_ac.importeEstado > totalImporte
          importeDisponible = issue_field_ac.importeEstado - totalImporte
          totalImporte = issue_field_ac.importeEstado
          chart_view.set_mensajeAC("al importe estimado")
        end

        if issue_field_ac.importeEjecutado != nil && issue_field_ac.importeEjecutado > totalImporte
          importeDisponible = issue_field_ac.importeEjecutado - totalImporte
          totalImporte = issue_field_ac.importeEjecutado
          chart_view.set_mensajeAC("al importe final")
        end

        if importeDisponible > 0
          mapaG1["Disponible"] = importeDisponible
        end

        mapaTablaG1 = Hash.new  
        divisorDecimal = totalImporte*1.0
        mapaG1.each do |key, importe|
          mapaTablaG1[key] = (importe/divisorDecimal)*cienPorcien
        end
      end

      if !mapaTablaG1.nil?
        # Se ordena el mapa por key para que salga ordenado cronológicamente
        mapaTablaG1 = mapaTablaG1.sort.to_h
      end 

      chart_view.set_fieldsLinks(listaFieldsLinks)
      chart_view.set_acsG1(acsG1)   
      chart_view.set_mapaTablaG1(mapaTablaG1)
      if mapaTablaG1 != nil && mapaTablaG1.any? 
        Printers::ActuacionesIssues.pintarActuacionesIssues(chart_view)
      end
    end

    def self.obtenerValorCamposImporteOT(settings, tracker_fields, ot, campoImporte1g2n2, campoImporte2g2n2)
      valorFinalCore = nil
      valorEstimadoCore = nil

      if tracker_fields != nil && !tracker_fields.empty?
        tracker_fields.each do |field|
          if Issue.columns_hash[field].to_s != nil && Issue.columns_hash[field].to_s != '' && Issue.columns_hash[field].type != nil && Issue.columns_hash[field.to_s].type.to_s != nil && Issue.columns_hash[field.to_s].type.to_s != ''
            if ("core__" + field).sub(/_id$/, '') == settings.importe1g2n2
              if Issue.columns_hash[field.to_s].type.to_s == 'float'
                valorFinalCore = eval("ot." + (settings.importe1g2n2).sub("core__", ''))
              else
                Rails.logger.warn('Se ha elegido un campo no válido como importe (' + Issue.columns_hash[field.to_s].type.to_s + ').')
              end
            end

            if ("core__" + field).sub(/_id$/, '') == settings.importe2g2n2
              if Issue.columns_hash[field.to_s].type.to_s == 'float'
                valorEstimadoCore = eval("ot." + (settings.importe2g2n2).sub("core__", ''))
              else
                Rails.logger.warn('Se ha elegido un campo no válido como importe (' + Issue.columns_hash[field.to_s].type.to_s + ').')
              end
            end
          end
        end
      end

      if valorFinalCore == nil || valorFinalCore == 0
        if valorEstimadoCore != nil && valorEstimadoCore != 0
          importeEjecutado = valorEstimadoCore
        end
      else
        importeEjecutado = valorFinalCore
      end

      custom_field_values_ot = ot.custom_field_values

      if custom_field_values_ot != nil && !custom_field_values_ot.empty?
        for cfv_ot in custom_field_values_ot
          if campoImporte1g2n2 != nil && !campoImporte1g2n2.empty? && campoImporte1g2n2[0] != nil && cfv_ot.custom_field_id == campoImporte1g2n2[0].id && cfv_ot.value != nil && cfv_ot.value.to_i != 0
            valorFinalCustom = cfv_ot.value.to_i
          end

          if campoImporte2g2n2 != nil && !campoImporte2g2n2.empty? && campoImporte2g2n2[0] != nil && cfv_ot.custom_field_id == campoImporte2g2n2[0].id && cfv_ot.value != nil && cfv_ot.value.to_i != 0
            valorEstimadoCustom = cfv_ot.value.to_i
          end       
        end

        if valorFinalCustom == nil || valorFinalCustom == 0
          if valorEstimadoCustom != nil && valorEstimadoCustom != 0
            importeEjecutado = valorEstimadoCustom
          end
        else
          importeEjecutado = valorFinalCustom
        end
      end

      issue_fields = IndicatorsUtils::IssueFields.new
      issue_fields.set_importeEjecutado(importeEjecutado)
      
      return issue_fields
    end

    def self.obtenerValorCamposImporteAC(settings, tracker_fields, ot, campoImporte1g2n2, campoImporte2g2n2)
      valorFinalCore = nil
      valorEstimadoCore = nil

      if tracker_fields != nil && !tracker_fields.empty?
        tracker_fields.each do |field|
          if Issue.columns_hash[field].to_s != nil && Issue.columns_hash[field].to_s != '' && Issue.columns_hash[field].type != nil && Issue.columns_hash[field.to_s].type.to_s != nil && Issue.columns_hash[field.to_s].type.to_s != ''
            if ("core__" + field).sub(/_id$/, '') == settings.importe1g2n2
              if Issue.columns_hash[field.to_s].type.to_s == 'float'
                valorFinalCore = eval("ot." + (settings.importe1g2n2).sub("core__", ''))
              else
                Rails.logger.warn('Se ha elegido un campo no válido como importe (' + Issue.columns_hash[field.to_s].type.to_s + ').')
              end
            end

            if ("core__" + field).sub(/_id$/, '') == settings.importe2g2n2
              if Issue.columns_hash[field.to_s].type.to_s == 'float'
                valorEstimadoCore = eval("ot." + (settings.importe2g2n2).sub("core__", ''))
              else
                Rails.logger.warn('Se ha elegido un campo no válido como importe (' + Issue.columns_hash[field.to_s].type.to_s + ').')
              end
            end
          end
        end
      end

      custom_field_values_ot = ot.custom_field_values

      if custom_field_values_ot != nil && !custom_field_values_ot.empty?
        for cfv_ot in custom_field_values_ot
          if campoImporte1g2n2 != nil && !campoImporte1g2n2.empty? && campoImporte1g2n2[0] != nil && cfv_ot.custom_field_id == campoImporte1g2n2[0].id && cfv_ot.value != nil && cfv_ot.value.to_i != 0
            valorFinalCustom = cfv_ot.value.to_i
          end

          if campoImporte2g2n2 != nil && !campoImporte2g2n2.empty? && campoImporte2g2n2[0] != nil && cfv_ot.custom_field_id == campoImporte2g2n2[0].id && cfv_ot.value != nil && cfv_ot.value.to_i != 0
            valorEstimadoCustom = cfv_ot.value.to_i
          end       
        end

        if valorFinalCustom != nil && valorFinalCustom != 0
          valorFinalCore = valorFinalCustom
        end

        if valorEstimadoCustom != nil && valorEstimadoCustom != 0
          valorEstimadoCore = valorEstimadoCustom
        end
      end
      issue_fields = IndicatorsUtils::IssueFields.new
      issue_fields.set_importeEjecutado(valorFinalCore)
      issue_fields.set_importeEstado(valorEstimadoCore)
      
      return issue_fields
    end
  end
end