# Se importan las clases de utilidad
require 'charts/printers/sectores_contratos'

module Charts
  class GraficaSectoresContratos    
    # Método que calcula los datos para cargar la primera gráfica
    def self.calculaGraficaSectoresContratos(whereProject, tracker_fields, settings, chart_view)
      Rails.logger.info('Dentro de calculaGraficaSectoresContratos.')  
      tipospeticiong3n1 = ""
      estadosAcsg3n1 = ""

      tipospeticiong3n2 = ""
      importe1g3n2 = ""
      importe2g3n2 = ""
      agruparporg3 = ""
      
      if !settings.tipospeticiong3n1.nil? && settings.tipospeticiong3n1.any?
        tipospeticiong3n1 = settings.tipospeticiong3n1[0]
      end
      if !settings.estadosAcsg3n1.nil? && settings.estadosAcsg3n1.any?
        estadosAcsg3n1 = IssueStatus.where({id: settings.estadosAcsg3n1})
      end

      if !settings.tipospeticiong3n2.nil? && settings.tipospeticiong3n2.any?
        tipospeticiong3n2 = settings.tipospeticiong3n2[0]
      end     
      if !settings.importe1g3n2.nil?
        campoImporte1g3n2 = IssueCustomField.where({id: (settings.importe1g3n2).sub("core__", '').sub("custom__", '')})

        if campoImporte1g3n2 != nil && !campoImporte1g3n2.empty? && campoImporte1g3n2[0] != nil && campoImporte1g3n2[0].field_format != nil && campoImporte1g3n2[0].field_format.to_s != nil && campoImporte1g3n2[0].field_format.to_s != '' && campoImporte1g3n2[0].field_format.to_s != 'float'          
          campoImporte1g3n2 = nil
        end
      end
      if !settings.importe2g3n2.nil?
        campoImporte2g3n2 = IssueCustomField.where({id: (settings.importe2g3n2).sub("core__", '').sub("custom__", '')})

        if campoImporte2g3n2 != nil && !campoImporte2g3n2.empty? && campoImporte2g3n2[0] != nil && campoImporte2g3n2[0].field_format != nil && campoImporte2g3n2[0].field_format.to_s != nil && campoImporte2g3n2[0].field_format.to_s != '' && campoImporte2g3n2[0].field_format.to_s != 'float'          
          campoImporte2g3n2 = nil
        end
      end

      if !settings.agruparporg3.nil?
        campoAgruparPorg3 = IssueCustomField.where({id: (settings.agruparporg3).sub("core__", '').sub("custom__", '')})

        if campoAgruparPorg3 != nil && !campoAgruparPorg3.empty? && campoAgruparPorg3[0] != nil && campoAgruparPorg3[0].field_format != nil && campoAgruparPorg3[0].field_format.to_s != nil && campoAgruparPorg3[0].field_format.to_s != '' && campoAgruparPorg3[0].field_format.to_s != 'project'
          campoAgruparPorg3 = nil
        end
      end

      mapaG3 = Hash.new
      issuesOts = Array.new
      if tipospeticiong3n2 == $CONST_OT
        listaIdsIssues = CustomValue.where('value in (' + whereProject.ids.join(",")+')')

        if listaIdsIssues != nil && !listaIdsIssues.empty?
          listaIdsIssues.each do |customValue|
            issueGood = Issue.where({id: customValue.customized_id, tracker: tipospeticiong3n2, status: settings.estadosAcsg3n1})[0]
            if issueGood != nil
              issuesOts.push(issueGood)
            end
          end        
        end

        if issuesOts.nil? || !issuesOts.any?
          Rails.logger.info('No se encontraron issues (G3))')
        else
          Rails.logger.info('Se encontraron issues, se continúa con los cálculos (G3))')
          trackerAC = Tracker.where('name like ?', '%AC%')[0]
          listaFieldsLinks = Hash.new
          issueCustomField = IssueCustomField.where('name = \'Contrato\'')[0]
          $ID_CONST_CUSTFIELD = issueCustomField.id

          issuesOts.each do |ac|
            nombEid = "Sin Actuación"
            padre = ac.parent
            issue_fields = obtenerValorCamposImporteEstado(settings, tracker_fields, ac, campoImporte1g3n2, campoImporte2g3n2, issueCustomField)             

            if padre != nil && padre.tracker == trackerAC              
              nombEid = padre.subject
            end

            if mapaG3[nombEid] != nil
              if issue_fields.importeEjecutado != nil
                mapaG3[nombEid] = mapaG3[nombEid] + issue_fields.importeEjecutado
              end
            else
              if issue_fields.importeEjecutado != nil
                mapaG3[nombEid] = issue_fields.importeEjecutado
              else 
                mapaG3[nombEid] = 0
              end
            end

            fields_links = IndicatorsUtils::FieldsLinks.new
            fields_links.set_proy_ident("sistemas-de-informacion") 
            fields_links.set_estado(estadosAcsg3n1.ids.join("%7C"))
            fields_links.set_tipo($CONST_OT.id.to_s)           
            fields_links.set_contrato(whereProject.ids.join("%7C"))
            fields_links.set_tarea_padre(issue_fields.idenf_proy.to_s)          

            if listaFieldsLinks[nombEid] == nil
              #posicion 0
              cadena = fields_links.proy_ident + $SPLIT_CHAR
              #posicion 1
              cadena = cadena + fields_links.estado + $SPLIT_CHAR
              #posicion 2
              cadena = cadena + fields_links.tipo + $SPLIT_CHAR
              #posicion 3
              cadena = cadena + fields_links.contrato + $SPLIT_CHAR
              #posicion 4
              cadena = cadena + fields_links.tarea_padre
              listaFieldsLinks[nombEid] = cadena
            end
          end          
        end

        if !mapaG3.nil?
          mapaG3 = mapaG3.sort.to_h
        end

        chart_view.set_fieldsSectores(listaFieldsLinks)
        chart_view.set_mapaG3(mapaG3)
        linkActivado = settings.actLinkg2 != nil && settings.actLinkg2 == "true"
        Printers::SectoresContratos.pintarSectoresContratos(chart_view, linkActivado)
      else
        Rails.logger.info('El tipo de peticion que se debe de buscar es de ACTUACION, y no se ha indicado')
      end
    end

    def self.obtenerValorCamposImporteEstado(settings, tracker_fields, ot, campoImporte1g3n2, campoImporte2g3n2, issueCustomField)
      Rails.logger.debug('Dentro de obtenerValorCamposImporte.')
      importe = 0
      valorFinalCore = nil
      valorEstimadoCore = nil
      estado = ""

      if tracker_fields != nil && !tracker_fields.empty?
        tracker_fields.each do |field|
          if Issue.columns_hash[field].to_s != nil && Issue.columns_hash[field].to_s != '' && Issue.columns_hash[field].type != nil && Issue.columns_hash[field.to_s].type.to_s != nil && Issue.columns_hash[field.to_s].type.to_s != ''            
            if ("core__" + field).sub(/_id$/, '') == settings.importe1g3n2
              if Issue.columns_hash[field.to_s].type.to_s == 'float'
                valorFinalCore = eval("ot." + (settings.importe1g3n2).sub("core__", ''))
              else
                Rails.logger.warn('Se ha elegido un campo no válido como importe (' + Issue.columns_hash[field.to_s].type.to_s + ').')
              end
            end

            if ("core__" + field).sub(/_id$/, '') == settings.importe2g3n2
              if Issue.columns_hash[field.to_s].type.to_s == 'float'
                valorEstimadoCore = eval("ot." + (settings.importe2g3n2).sub("core__", ''))
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
          if campoImporte1g3n2 != nil && !campoImporte1g3n2.empty? && campoImporte1g3n2[0] != nil && cfv_ot.custom_field_id == campoImporte1g3n2[0].id && cfv_ot.value != nil && cfv_ot.value.to_i != 0
            valorFinalCustom = cfv_ot.value.to_i
          end

          if campoImporte2g3n2 != nil && !campoImporte2g3n2.empty? && campoImporte2g3n2[0] != nil && cfv_ot.custom_field_id == campoImporte2g3n2[0].id && cfv_ot.value != nil && cfv_ot.value.to_i != 0
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
      issue_fields.set_nombre(ot.status.name)

      if issueCustomField != nil         
        if ot.parent != nil
          issue_fields.set_nombre_proy(ot.parent.subject)
          issue_fields.set_idenf_proy(ot.parent.id.to_s)
        end
      end
      return issue_fields
    end
  end
end