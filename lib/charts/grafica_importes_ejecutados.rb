# Se importan las clases de utilidad
require 'charts/printers/importes_ejecutados'

module Charts
  class GraficaImportesEjecutados
    # Método que calcula los datos para cargar la segunda gráfica
    def self.calculaGraficaImportesEjecutados(whereProject, tracker_fields, settings, chart_view, esContrato, stacked)
      Rails.logger.info('Dentro de calculaGraficaImportesEjecutados.')
      tipopeticiong2n1 = ""
      tipopeticiong2n2 = "" 
      idTPActuacion = nil    

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
      if !esContrato && stacked && settings.agruparporg2 != nil && !settings.agruparporg2.empty?
        montarGraficaImportesStacked(true, tracker_fields, settings, chart_view, whereProject, tipopeticiong2n1, tipopeticiong2n2, campoAgruparPorg2, campoImporte1g2n2, campoImporte2g2n2, campoFechaFing2n2)
      elsif esContrato && settings.agruparporg2 != nil && !settings.agruparporg2.empty?
        montarGraficaContStacked(tracker_fields, settings, chart_view, whereProject, tipopeticiong2n1, tipopeticiong2n2, campoAgruparPorg2, campoImporte1g2n2, campoImporte2g2n2, campoFechaFing2n2)
      else
        montarGraficaNormal(stacked, tracker_fields, settings, chart_view, whereProject, tipopeticiong2n1, tipopeticiong2n2, campoAgruparPorg2, campoImporte1g2n2, campoImporte2g2n2, campoFechaFing2n2)
      end
    end

    def self.montarGraficaNormal(esSI, tracker_fields, settings, chart_view, whereProject, tipopeticiong2n1, tipopeticiong2n2, campoAgruparPorg2, campoImporte1g2n2, campoImporte2g2n2, campoFechaFing2n2)
      mapaG2 = Hash.new      
      issuesOts = Array.new
      if tipopeticiong2n1 == $CONST_OT.id || tipopeticiong2n2.id == $CONST_OT.id
        if esSI
           issuesOts = Issue.where({tracker: tipopeticiong2n2.id, project: whereProject, status: settings.estadosOtsg2n2})
        else 
          listaIdsIssues = CustomValue.where('value in (' + whereProject.ids.join(",")+')')

          if listaIdsIssues != nil && !listaIdsIssues.empty?
            listaIdsIssues.each do |customValue|
              issueGood = Issue.where({id: customValue.customized_id, tracker: tipopeticiong2n2.id, status: settings.estadosOtsg2n2})[0]
              if issueGood != nil
                issuesOts.push(issueGood)
              end
            end        
          end
        end
      end

      if issuesOts != nil && !issuesOts.empty? 
        issueCustomField = IssueCustomField.where('name = \'Contrato\'')[0]
        $ID_CONST_CUSTFIELD = issueCustomField.id

        issuesOts.each do |ot|
          issue_fields = obtenerValorCamposImporteYFechaOT(esSI, settings, tracker_fields, ot, issueCustomField, campoAgruparPorg2, campoImporte1g2n2, campoImporte2g2n2, campoFechaFing2n2)
          importe = issue_fields.importeEjecutado
          anyo = issue_fields.anyo
          
          if importe == nil
            importe = 0
          end
          
          if mapaG2[anyo] == nil
            mapaG2[anyo] = importe
          else
            importe += mapaG2[anyo]
            mapaG2[anyo] = importe
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

    def self.montarGraficaImportesStacked(esSI, tracker_fields, settings, chart_view, whereProject, tipopeticiong2n1, tipopeticiong2n2, campoAgruparPorg2, campoImporte1g2n2, campoImporte2g2n2, campoFechaFing2n2)
      Rails.logger.info('Dentro de calculaGraficaImportesStacked.')
      mapaG2 = Hash.new
      issuesOts = nil
      listaFieldsLinks = Hash.new

      if tipopeticiong2n2.id == $CONST_OT.id
        issuesOts = Issue.where({tracker: tipopeticiong2n2.id, project: whereProject, status: settings.estadosOtsg2n2})
      end
      issueCustomField = IssueCustomField.where('name = \'Contrato\'')[0]
      $ID_CONST_CUSTFIELD = issueCustomField.id
      if issuesOts != nil && !issuesOts.empty?    
        issuesOts.each do |ot|
          issue_fields = obtenerValorCamposImporteYFechaOT(esSI, settings, tracker_fields, ot, issueCustomField, campoAgruparPorg2, campoImporte1g2n2, campoImporte2g2n2, campoFechaFing2n2)

          if issue_fields.nombre_proy != nil
            nombre = issue_fields.nombre_proy
          else
            nombre = "Sin Contrato Asociado"
          end
          importe = issue_fields.importeEjecutado
          anyo = issue_fields.anyo

          if importe == nil
            importe = 0
          end

          fields_links = IndicatorsUtils::FieldsLinks.new
          fields_links.set_proy_ident($CONST_ID_PROJ) 
          fields_links.set_estado(settings.estadosOtsg2n2.join("%7C"))
          fields_links.set_tipo($CONST_OT.id.to_s)
          if (anyo != "Sin año")
            fields_links.set_fechaFin_desde(anyo+'-01-01')
            fields_links.set_fechaFin_hasta(anyo+'-12-31')
          else 
            fields_links.set_fechaFin_desde('-1')
            fields_links.set_fechaFin_hasta('-1')
          end
          idProyecto = ot.custom_field_value(issueCustomField.id)
          if idProyecto != nil
            fields_links.set_contrato(ot.custom_field_value(issueCustomField.id))
          else
            fields_links.set_contrato('')
          end
          fields_links.set_tarea_padre('')

          anyoImporteHash = Hash.new
          if mapaG2[nombre] != nil          
            anyoImporteHash = mapaG2[nombre]
          end
          montarMapaStacked(nombre, importe, anyo, anyoImporteHash, mapaG2)

          if listaFieldsLinks[nombre+anyo.to_s] == nil
            #posicion 0
            cadena = fields_links.proy_ident + $SPLIT_CHAR
            #posicion 1
            cadena = cadena + fields_links.estado + $SPLIT_CHAR
            #posicion 2
            cadena = cadena + fields_links.tipo + $SPLIT_CHAR
            #posicion 3
            cadena = cadena + fields_links.fechaFin_desde + $SPLIT_CHAR
            #posicion 4
            cadena = cadena + fields_links.fechaFin_hasta + $SPLIT_CHAR
            #posicion 5
            cadena = cadena + fields_links.contrato + $SPLIT_CHAR
            #posicion 6
            cadena = cadena + fields_links.tarea_padre
            listaFieldsLinks[nombre+anyo.to_s] = cadena
          end
        end
      else 
        Rails.logger.info('calculaGraficaImportesStacked no se ha encontrado nada')
      end      

      if !mapaG2.nil?
        # Se ordena el mapa por key para que salga ordenado cronológicamente
        mapaG2 = mapaG2.sort.to_h
      end
      chart_view.set_fieldsLinks(listaFieldsLinks)
      chart_view.set_mapaG2(mapaG2)
      linkActivado = settings.actLinkg2 != nil && settings.actLinkg2 == "true"
      Printers::ImportesEjecutados.pintarImportesEjecutadosStacked(chart_view, settings.actLegendg2, linkActivado, whereProject)
    end

    def self.montarGraficaContStacked(tracker_fields, settings, chart_view, whereProject, tipopeticiong2n1, tipopeticiong2n2, campoAgruparPorg2, campoImporte1g2n2, campoImporte2g2n2, campoFechaFing2n2)
      Rails.logger.info('Dentro de montarGraficaContStacked.')
      mapaG2 = Hash.new
      issuesOts = Array.new
      listaFieldsLinks = Hash.new

      if tipopeticiong2n1 == $CONST_OT.id || tipopeticiong2n2.id == $CONST_OT.id        
        listaIdsIssues = CustomValue.where('value in (' + whereProject.ids.join(",")+')')

        if listaIdsIssues != nil && !listaIdsIssues.empty?
          listaIdsIssues.each do |customValue|
            issueGood = Issue.where({id: customValue.customized_id, tracker: tipopeticiong2n2.id, status: settings.estadosOtsg2n2})[0]
            if issueGood != nil
              issuesOts.push(issueGood)
            end
          end        
        end
      end    

      if issuesOts != nil && !issuesOts.empty? 
        issueCustomField = IssueCustomField.where('name = \'Contrato\'')[0]
        $ID_CONST_CUSTFIELD = issueCustomField.id

        issuesOts.each do |ot|
          issue_fields = obtenerValorCamposImporteYFechaOT(false, settings, tracker_fields, ot, issueCustomField, campoAgruparPorg2, campoImporte1g2n2, campoImporte2g2n2, campoFechaFing2n2)
          #Los campos nombre_proy y idenf_proy son la tarea padre en este caso, la ac
          if issue_fields.nombre_proy != nil
            nombre = issue_fields.nombre_proy
          else
            nombre = "Sin Actuacion Asociada"
          end
          importe = issue_fields.importeEjecutado
          anyo = issue_fields.anyo

          if importe == nil
            importe = 0
          end

          fields_links = IndicatorsUtils::FieldsLinks.new
          fields_links.set_proy_ident("sistemas-de-informacion") 
          fields_links.set_estado(settings.estadosOtsg2n2.join("%7C"))
          fields_links.set_tipo($CONST_OT.id.to_s)
          if (anyo != "Sin año")
            fields_links.set_fechaFin_desde(anyo+'-01-01')
            fields_links.set_fechaFin_hasta(anyo+'-12-31')
          else 
            fields_links.set_fechaFin_desde('-1')
            fields_links.set_fechaFin_hasta('-1')
          end
          fields_links.set_contrato(whereProject.ids.join("%7C"))
          fields_links.set_tarea_padre(issue_fields.idenf_proy.to_s)

          anyoImporteHash = Hash.new
          if mapaG2[nombre] != nil          
            anyoImporteHash = mapaG2[nombre]
          end
          montarMapaStacked(nombre, importe, anyo, anyoImporteHash, mapaG2)

          if listaFieldsLinks[nombre+anyo.to_s] == nil
            #posicion 0
            cadena = fields_links.proy_ident + $SPLIT_CHAR
            #posicion 1
            cadena = cadena + fields_links.estado + $SPLIT_CHAR
            #posicion 2
            cadena = cadena + fields_links.tipo + $SPLIT_CHAR
            #posicion 3
            cadena = cadena + fields_links.fechaFin_desde + $SPLIT_CHAR
            #posicion 4
            cadena = cadena + fields_links.fechaFin_hasta + $SPLIT_CHAR
            #posicion 5
            cadena = cadena + fields_links.contrato + $SPLIT_CHAR
            #posicion 6
            cadena = cadena + fields_links.tarea_padre
            listaFieldsLinks[nombre+anyo.to_s] = cadena
          end
        end
      else 
        Rails.logger.info('montarGraficaContStacked no se ha encontrado nada')
      end      

      if !mapaG2.nil?
        # Se ordena el mapa por key para que salga ordenado cronológicamente
        mapaG2 = mapaG2.sort.to_h
      end
      chart_view.set_fieldsLinks(listaFieldsLinks)
      chart_view.set_mapaG2(mapaG2)
      linkActivado = settings.actLinkg2 != nil && settings.actLinkg2 == "true"
      Printers::ImportesEjecutados.pintarImpEjecContStacked(chart_view, settings.actLegendg2, linkActivado, whereProject)
    end

    def self.montarMapaStacked(nombre, importe, anyo, anyoImporteHash, mapaG2)
      if anyoImporteHash[anyo] == nil
        anyoImporteHash[anyo] = importe
        mapaG2[nombre] = anyoImporteHash
      else
        anyoImporteHash = mapaG2[nombre]
        importe += anyoImporteHash[anyo]
        anyoImporteHash[anyo] = importe
        mapaG2[nombre] = anyoImporteHash
      end
    end

    # Método que obtiene de la OT dada el valor de los campos de importe y fecha
    def self.obtenerValorCamposImporteYFechaOT(esSI, settings, tracker_fields, ot, issueCustomField, campoAgruparPorg2, campoImporte1g2n2, campoImporte2g2n2, campoFechaFing2n2)
      Rails.logger.debug('Dentro de obtenerValorCamposImporteYFechaOT.')
      agruparPor = nil
      anyo = I18n.t("field_no_date", default: "0")

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

      if issueCustomField != nil 
        if esSI
          projectId = ot.custom_field_value(issueCustomField.id)
          if projectId != nil && !projectId.empty?
            project = Project.where('id = ' + projectId)[0]
            if project != nil
              issue_fields.set_nombre_proy(project.name)
              issue_fields.set_idenf_proy(project.identifier)
            end
          end
        else 
          if ot.parent != nil
            issue_fields.set_nombre_proy(ot.parent.subject)
            issue_fields.set_idenf_proy(ot.parent.id.to_s)
          end
        end
      end
      return issue_fields
    end
  end
end