# Se importan las clases de utilidad
require 'charts/printers/importes_ejecutados'

module Charts
  class GraficaImportesEjecutados
    # Método que calcula los datos para cargar la segunda gráfica
    def self.calculaGraficaImportesEjecutados(whereProject, tracker_fields, settings, chart_view)
      Rails.logger.info('Dentro de calculaGraficaImportesEjecutados.')

      tipopeticiong2n1 = ""
      tipopeticiong2n2 = ""
      issuesOtsG2 = Array.new

      # Se reciben los parametros de la configuracion
      # y se prepara la grafica de importes ejecutados por año
      Rails.logger.info('Se reciben los parametros de la configuracion y se prepara la grafica de importes ejecutados por año')
      if !settings.tipospeticiong2n1.nil? && settings.tipospeticiong2n1.any?
        tipopeticiong2n1 = settings.tipospeticiong2n1[0]
      end

      if !settings.tipospeticiong2n2.nil? && settings.tipospeticiong2n2.any?
        tipopeticiong2n2 = settings.tipospeticiong2n2[0]
      end

      campoAgruparPorg2 = nil
      campoImporte1g2n2 = nil
      campoImporte2g2n2 = nil
      campoFechaFing2n2 = nil

      if !settings.agruparporg2.nil?
        campoAgruparPorg2 = IssueCustomField.where({id: (settings.agruparporg2).sub("core__", '').sub("custom__", '')})

        if campoAgruparPorg2 != nil && !campoAgruparPorg2.empty? && campoAgruparPorg2[0] != nil && campoAgruparPorg2[0].field_format != nil && campoAgruparPorg2[0].field_format.to_s != nil && campoAgruparPorg2[0].field_format.to_s != '' && campoAgruparPorg2[0].field_format.to_s != 'project'
          Rails.logger.warn('Se ha elegido un campo no válido como proyecto (' + campoAgruparPorg2[0].field_format.to_s + ').')
          campoAgruparPorg2 = nil
        end
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
      if !settings.fechaFing2n2.nil?
        campoFechaFing2n2 = IssueCustomField.where({id: (settings.fechaFing2n2).sub("core__", '').sub("custom__", '')})

        if campoFechaFing2n2 != nil && !campoFechaFing2n2.empty? && campoFechaFing2n2[0] != nil && campoFechaFing2n2[0].field_format != nil && campoFechaFing2n2[0].field_format.to_s != nil && campoFechaFing2n2[0].field_format.to_s != '' && campoFechaFing2n2[0].field_format.to_s != 'date'
          Rails.logger.warn('Se ha elegido un campo no válido como fecha (' + campoFechaFing2n2[0].field_format.to_s + ').')
          campoFechaFing2n2 = nil
        end
      end

      mapaG2 = Hash.new
      
      # Se obtienen las AC con el estado indicado
      Rails.logger.info('Se obtienen las AC con el estado indicado (G2)')
      acsG2 = Issue.where({project: whereProject, tracker: tipopeticiong2n1, status: settings.estadosAcsg2n1})

      if acsG2.nil? || !acsG2.any?
        # Si no hay AC se obtendrán directamente las OT del contenedor
        Rails.logger.info('No se encontraron ACs (G2))')
        issuesOtsG2 = Issue.where({project: whereProject, tracker: tipopeticiong2n2, status: settings.estadosOtsg2n2})
      else
        Rails.logger.info('Se encontraron ACs, se continúa con los cálculos (G2))')
        otsAux = Issue.where({tracker: tipopeticiong2n2, status: settings.estadosOtsg2n2})
        # Por cada AC se obtendrán sus OT
        Rails.logger.info('Por cada AC se obtendrán las OT (G2)')
        acsG2.each do |ac|
          if otsAux != nil && !otsAux.empty?
            otsAux.each do |ot|
              if ot.parent_id == ac.id
                issuesOtsG2.push(ot)
              end
            end
          end
        end
      end

      if issuesOtsG2 != nil && !issuesOtsG2.empty?
        issuesOtsG2.each do |ot|
          issue_fields = obtenerValorCamposImporteYFechaOT(settings, tracker_fields, ot, campoAgruparPorg2, campoImporte1g2n2, campoImporte2g2n2, campoFechaFing2n2)

          importe = issue_fields.importeEjecutado
          anyo = issue_fields.anyo
					
					if importe == nil
					  importe = 0
					end

          if mapaG2 != nil
              if mapaG2[anyo] == nil
                  mapaG2[anyo] = importe
              else
                  importe += mapaG2[anyo]
                  mapaG2[anyo] = importe
              end
          end
        end
      end

      if !mapaG2.nil?
        # Se ordena el mapa por key para que salga ordenado cronológicamente
        mapaG2 = mapaG2.sort.to_h
      end

      chart_view.set_mapaG2(mapaG2)

      Printers::ImportesEjecutados.pintarImportesEjecutados(chart_view)
    end

    # Método que obtiene de la OT dada el valor de los campos de importe y fecha
    def self.obtenerValorCamposImporteYFechaOT(settings, tracker_fields, ot, campoAgruparPorg2, campoImporte1g2n2, campoImporte2g2n2, campoFechaFing2n2)
      Rails.logger.info('Dentro de obtenerValorCamposImporteYFechaOT.')
      agruparPor = nil
      anyo = I18n.t("field_no_date", default: "0")
      importe = 0

      agruparPorCore = nil
      valorFinalCore = nil
      valorEstimadoCore = nil
      fechaFinCore = nil

      if tracker_fields != nil && !tracker_fields.empty?
        tracker_fields.each do |field|
          if Issue.columns_hash[field].to_s != nil && Issue.columns_hash[field].to_s != '' && Issue.columns_hash[field].type != nil && Issue.columns_hash[field.to_s].type.to_s != nil && Issue.columns_hash[field.to_s].type.to_s != ''
            if ("core__" + field).sub(/_id$/, '') == settings.agruparporg2
              if Issue.columns_hash[field.to_s].type.to_s == 'project'
                agruparPorCore = eval("ot." + (settings.agruparporg2).sub("core__", ''))
              else
                Rails.logger.warn('Se ha elegido un campo no válido como proyecto (' + Issue.columns_hash[field.to_s].type.to_s + ').')
              end
            end

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

            if ("core__" + field).sub(/_id$/, '') == settings.fechaFing2n2
              if Issue.columns_hash[field.to_s].type.to_s == 'date'
                fechaFinCore = eval("ot." + (settings.fechaFing2n2).sub("core__", ''))
              else
                Rails.logger.warn('Se ha elegido un campo no válido como fecha (' + Issue.columns_hash[field.to_s].type.to_s + ').')
              end
            end
          end
        end
      end

      if agruparPorCore != nil && agruparPorCore != ''
        agruparPor = agruparPorCore
      end

      if valorFinalCore == nil || valorFinalCore == 0
        if valorEstimadoCore != nil && valorEstimadoCore != 0
          importeEjecutado = valorEstimadoCore
        end
      else
        importeEjecutado = valorFinalCore
      end

      if fechaFinCore != nil && fechaFinCore != ''
        anyo = (fechaFinCore.to_date).strftime("%Y")
      end

      custom_field_values_ot = ot.custom_field_values

      if custom_field_values_ot != nil && !custom_field_values_ot.empty?
        for cfv_ot in custom_field_values_ot
          if campoAgruparPorg2 != nil && !campoAgruparPorg2.empty? && campoAgruparPorg2[0] != nil && cfv_ot.custom_field_id == campoAgruparPorg2[0].id && cfv_ot.value != nil && cfv_ot.value != ''
            agruparPorCustom = cfv_ot.value
          end

          if campoImporte1g2n2 != nil && !campoImporte1g2n2.empty? && campoImporte1g2n2[0] != nil && cfv_ot.custom_field_id == campoImporte1g2n2[0].id && cfv_ot.value != nil && cfv_ot.value.to_i != 0
            valorFinalCustom = cfv_ot.value.to_i
          end

          if campoImporte2g2n2 != nil && !campoImporte2g2n2.empty? && campoImporte2g2n2[0] != nil && cfv_ot.custom_field_id == campoImporte2g2n2[0].id && cfv_ot.value != nil && cfv_ot.value.to_i != 0
            valorEstimadoCustom = cfv_ot.value.to_i
          end

          if campoFechaFing2n2 != nil && !campoFechaFing2n2.empty? && campoFechaFing2n2[0] != nil && cfv_ot.custom_field_id == campoFechaFing2n2[0].id && cfv_ot.value != nil && cfv_ot.value != ''
            anyo = (cfv_ot.value.to_date).strftime("%Y")
          end
        end

        if agruparPorCustom != nil && agruparPorCustom != ''
          agruparPor = agruparPorCustom
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
      issue_fields.set_anyo(anyo)

      return issue_fields
    end
  end
end