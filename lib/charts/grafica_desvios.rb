# Se importan las clases de utilidad
require 'charts/printers/desvios'

module Charts
  class GraficaDesvios
    # Método que calcula los datos para cargar la segunda gráfica
    def self.calculaGraficaDesvios(whereProject, tracker_fields, settings, chart_view, esSis)
      Rails.logger.info('Dentro de calculaGraficaImportesDesvios.')
      montarGraficaImportesDesvios(whereProject, tracker_fields, settings, chart_view, esSis)
      montarGraficaPlazosDesvios(whereProject, tracker_fields, settings, chart_view, esSis)
    end

    def self.montarGraficaImportesDesvios(whereProject, tracker_fields, settings, chart_view, esSis)
      Rails.logger.info('Dentro de montarGraficaImportesDesvios.')
      mapaG4 = Hash.new
      mapaG4_resumen = Hash.new
      issuesOts = nil
      tipopeticiong4n1 = ""
      #El estado estadoPeticiong4n1 y el tipo de campo personalizado issueCustomField 
      #elegible en la configuracion se han quitad, no se desea que aparezcan para poder 
      #ser seleccionados
      estadoPeticiong4n1 = ""
      issueCustomField = ""
      listaFieldsLinks = Hash.new
      campoAgruparPorg4 = nil

      limiteg4_1 = nil
      limiteg4_2 = nil
      limiteg4_3 = nil
      limiteg4_4 = nil
      limiteg4_5 = nil

      if !settings.tipospeticiong4n1.nil? && settings.tipospeticiong4n1.any?
        tipopeticiong4n1 = settings.tipospeticiong4n1[0]
      end

      if !settings.estadosg4n1.nil? && settings.estadosg4n1.any?
        estadoPeticiong4n1 = settings.estadosg4n1
      end

      if !settings.campo4n1.nil? && settings.campo4n1.any?
        issueCustomField = settings.campo4n1[0]
      else
        issueCustomField = IssueCustomField.where('name like \'%Importe%\' and is_computed = true')[0]
      end

      if !settings.agruparporg4.nil?
        campoAgruparPorg4 = IssueCustomField.where({id: (settings.agruparporg4).sub("core__", '').sub("custom__", '')})
        if campoAgruparPorg4 != nil && !campoAgruparPorg4.empty? && campoAgruparPorg4[0] != nil && campoAgruparPorg4[0].field_format != nil && campoAgruparPorg4[0].field_format.to_s != nil && campoAgruparPorg4[0].field_format.to_s != '' && campoAgruparPorg4[0].field_format.to_s != 'project'
          campoAgruparPorg4 = nil
        else
          campoAgruparPorg4 = campoAgruparPorg4[0]
          $ID_CONST_CUSTFIELD = campoAgruparPorg4.id
        end
      end

      if !settings.limit_g4_1.nil?
        limiteg4_1 = settings.limit_g4_1
      end

      if !settings.limit_g4_2.nil?
        limiteg4_2 = settings.limit_g4_2
      end

      if !settings.limit_g4_3.nil?
        limiteg4_3 = settings.limit_g4_3
      end

      if !settings.limit_g4_4.nil?
        limiteg4_4 = settings.limit_g4_4
      end

      if !settings.limit_g4_5.nil?
        limiteg4_5 = settings.limit_g4_5
      end

      if esSis
        issuesOts = Issue.where({tracker: tipopeticiong4n1.id, project: whereProject})
      else
        listaIdsIssues = CustomValue.where('value in (' + whereProject.ids.join(",")+')')
        if listaIdsIssues != nil && !listaIdsIssues.empty?
          issuesOts = Array.new
          listaIdsIssues.each do |issueL|
            issueGood = Issue.where({id: issueL.customized_id, tracker: tipopeticiong4n1.id})[0]
            if issueGood != nil
              issuesOts.push(issueGood)
            end
          end        
        end
      end

      if issuesOts != nil && !issuesOts.empty? 
        posicion1_name = 'Desvio <= ' + limiteg4_1.to_s
        posicion2_name = limiteg4_1.to_s + ' < Desvio <= ' + limiteg4_2.to_s
        posicion3_name = limiteg4_2.to_s + ' < Desvio <= ' + limiteg4_3.to_s
        posicion4_name = limiteg4_3.to_s + ' < Desvio <= ' + limiteg4_4.to_s
        posicion5_name = limiteg4_4.to_s + ' < Desvio <= ' + limiteg4_5.to_s
        posicion6_name = 'Desvio > ' + limiteg4_5.to_s

        #Poner todo en 0, ahora mismo tiene valores porque es una prueba
        mapaG4[posicion1_name] = 0
        mapaG4[posicion2_name] = 0
        mapaG4[posicion3_name] = 0
        mapaG4[posicion4_name] = 0
        mapaG4[posicion5_name] = 0
        mapaG4[posicion6_name] = 0

        #Tabla resumen de desvio de plazos
        mediaArray = Array.new
        media = 0
        minimo = 0
        maximo = 0

        distanciaArrayTipica = Array.new
        distanciaTotal = 0
        tipica = 0

        guardarUnaVez = true

        estimadoICF = IssueCustomField.where('name like \'%estimado%\'')[0]
        finalICF = IssueCustomField.where('name like \'%final%\'')[0]

        issuesOts.each do |ot|
          issue_fields = obtenerValorDesvioOT(ot, issueCustomField, true)
          calculo = issue_fields.campo_calc_importe

          if !calculo.nil?
            if guardarUnaVez
              minimo = calculo
              maximo = calculo
              guardarUnaVez = false
            end
            
            mediaArray.push(calculo)

            if calculo < minimo
              minimo = calculo
            end
            if calculo > maximo
              maximo = calculo
            end 

            key = posicion1_name
            if calculo > limiteg4_1.to_i && calculo <= limiteg4_2.to_i
              key = posicion2_name
            elsif calculo > limiteg4_2.to_i && calculo <= limiteg4_3.to_i
              key = posicion3_name
            elsif calculo > limiteg4_3.to_i && calculo <= limiteg4_4.to_i
              key = posicion4_name
            elsif calculo > limiteg4_4.to_i && calculo <= limiteg4_5.to_i
              key = posicion5_name
            elsif calculo > limiteg4_5.to_i
              key = posicion6_name
            end

            key = key
            if !mapaG4[key].nil?
              mapaG4[key] = 1 + mapaG4[key]
            else 
              mapaG4[key] = 1
            end

            fields_links = IndicatorsUtils::FieldsLinks.new
            if esSis
              fields_links.set_proy_ident($CONST_ID_PROJ)
            else
              fields_links.set_proy_ident(I18n.t("proy_sis_info").downcase)              
            end
            #fields_links.set_estado(estadoPeticiong4n1.join("%7C"))
            fields_links.set_tipo(tipopeticiong4n1.id.to_s)
            idContrato = ot.custom_field_value(campoAgruparPorg4.id)
            idCampo = issueCustomField.id.to_s

            if idContrato != nil
              fields_links.set_contrato(idContrato)
            else
              fields_links.set_contrato('')
            end

            if idCampo != nil
              fields_links.set_id_cf_desvio(idCampo)
            else
              fields_links.set_id_cf_desvio('')
            end

            case key
            when posicion1_name
              fields_links.set_desvio(limiteg4_1.to_s)
            when posicion2_name
              fields_links.set_desvio(limiteg4_1.to_s+'%7C'+limiteg4_2.to_s)
            when posicion3_name
              fields_links.set_desvio(limiteg4_2.to_s+'%7C'+limiteg4_3.to_s)
            when posicion4_name
              fields_links.set_desvio(limiteg4_3.to_s+'%7C'+limiteg4_4.to_s)
            when posicion5_name
              fields_links.set_desvio(limiteg4_4.to_s+'%7C'+limiteg4_5.to_s)
            when posicion6_name
              fields_links.set_desvio(limiteg4_5.to_s)
            end

            fields_links.set_tarea_padre(estimadoICF.id.to_s+'%7C'+finalICF.id.to_s)
            
            if listaFieldsLinks[key] == nil
              #posicion 0
              cadena = fields_links.proy_ident + $SPLIT_CHAR
              #posicion 1
              #cadena = cadena + fields_links.estado + $SPLIT_CHAR
              #posicion 2
              cadena = cadena + fields_links.tipo + $SPLIT_CHAR
              #posicion 3
              cadena = cadena + fields_links.id_cf_desvio + $SPLIT_CHAR
              #posicion 4
              cadena = cadena + fields_links.desvio + $SPLIT_CHAR
              #posicion 5 utilizada para totalizar importes finales y estimados
              cadena = cadena + fields_links.tarea_padre + $SPLIT_CHAR
              #posicion 6
              cadena = cadena + fields_links.contrato
              listaFieldsLinks[key] = cadena
            else 
              listaFieldsLinks[key] = listaFieldsLinks[key] +'%7C'+ fields_links.contrato
            end
          end          
        end

        #Sacar la MEDIA y la DESVIACION TIPICA
        if !mediaArray.nil? && !mediaArray.empty?
          #Calculamos la media primeramente sumando los valores entre el total de valores
          mediaArray.each do |valor|
            media = valor + media
          end
          media = media / mediaArray.size

          #La informacion de desviacion tipica no se quiere mostrar por ahora
          #pero NO BORRAR, puede ser que sea necesaria mas adelante

          #Calculamos la distancia de cada valor restando la media y calculando su cuadrado 
          #y el resultado lo guardamos en un array para usar luego otro calculo
          #mediaArray.each do |valor|
          #  distancia = (valor - media)**2
          #  distanciaArrayTipica.push(distancia)
          #end

          #Calculamos la suma de los valores de distancia entre el total de valores que tenemos
          #distanciaArrayTipica.each do |valor|
          #  distanciaTotal = valor + distanciaTotal
          #end
          #distanciaTotal = distanciaTotal / mediaArray.size

          #Calculamos la raiz cuadrada de la distancia total y el resultado es la desviacion
          #tipica = distanciaTotal**0.5

          mapaG4_resumen['Media']= media
          mapaG4_resumen['Minima']= minimo
          mapaG4_resumen['Maxima']= maximo
          #mapaG5_resumen['Tipica (σ)']= tipica
        end
      else 
        Rails.logger.info('montarGraficaImportesDesvios no se ha encontrado nada')
      end
      chart_view.set_fieldsLinksg4(listaFieldsLinks)
      chart_view.set_mapaG4(mapaG4)
      chart_view.set_mapaG4_resumen(mapaG4_resumen)
      linkActivado = settings.actLinkg2 != nil && settings.actLinkg2 == "true"
      Printers::Desvios.pintarImportesDesvios(chart_view, linkActivado)
    end

    def self.montarGraficaPlazosDesvios(whereProject, tracker_fields, settings, chart_view, esSis)
      Rails.logger.info('Dentro de montarGraficaPlazosDesvios.')
      mapaG5 = Hash.new
      mapaG5_resumen = Hash.new
      issuesOts = nil
      tipopeticiong5n1 = ""
      estadoPeticiong5n1 = ""
      issueCustomField = ""
      listaFieldsLinks = Hash.new
      campoAgruparPorg5 = nil

      limiteg5_1 = nil
      limiteg5_2 = nil
      limiteg5_3 = nil
      limiteg5_4 = nil
      limiteg5_5 = nil

      if !settings.tipospeticiong5n1.nil? && settings.tipospeticiong5n1.any?
        tipopeticiong5n1 = settings.tipospeticiong5n1[0]
      end

      if !settings.estadosg5n1.nil? && settings.estadosg5n1.any?
        estadoPeticiong5n1 = settings.estadosg5n1
      end

      if !settings.campo5n1.nil? && settings.campo5n1.any?
        issueCustomField = settings.campo5n1[0]
      else
        issueCustomField = IssueCustomField.where('name like \'%Plazo%\' and is_computed = true')[0]
      end

      if !settings.agruparporg5.nil?
        campoAgruparPorg5 = IssueCustomField.where({id: (settings.agruparporg5).sub("core__", '').sub("custom__", '')})

        if campoAgruparPorg5 != nil && !campoAgruparPorg5.empty? && campoAgruparPorg5[0] != nil && campoAgruparPorg5[0].field_format != nil && campoAgruparPorg5[0].field_format.to_s != nil && campoAgruparPorg5[0].field_format.to_s != '' && campoAgruparPorg5[0].field_format.to_s != 'project'
          campoAgruparPorg5 = nil
        else 
          campoAgruparPorg5 = campoAgruparPorg5[0]
          $ID_CONST_CUSTFIELD = campoAgruparPorg5.id
        end
      end

      if !settings.limit_g5_1.nil?
        limiteg5_1 = settings.limit_g5_1
      end

      if !settings.limit_g5_2.nil?
        limiteg5_2 = settings.limit_g5_2
      end

      if !settings.limit_g5_3.nil?
        limiteg5_3 = settings.limit_g5_3
      end

      if !settings.limit_g5_4.nil?
        limiteg5_4 = settings.limit_g5_4
      end

      if !settings.limit_g5_5.nil?
        limiteg5_5 = settings.limit_g5_5
      end

      if esSis
        #issuesOts = Issue.where({tracker: tipopeticiong5n1.id, project: whereProject, status: estadoPeticiong5n1})
        issuesOts = Issue.where({tracker: tipopeticiong5n1.id, project: whereProject})
      else
        listaIdsIssues = CustomValue.where('value in (' + whereProject.ids.join(",")+')')
        if listaIdsIssues != nil && !listaIdsIssues.empty?
          issuesOts = Array.new
          listaIdsIssues.each do |issueL|
            #issueGood = Issue.where({id: issueL.customized_id, tracker: tipopeticiong5n1.id, status: estadoPeticiong5n1})[0]
            issueGood = Issue.where({id: issueL.customized_id, tracker: tipopeticiong5n1.id})[0]
            if issueGood != nil
              issuesOts.push(issueGood)
            end
          end        
        end
      end

      if issuesOts != nil && !issuesOts.empty?
        posicion1_name = 'Desvio <= ' + limiteg5_1.to_s
        posicion2_name = limiteg5_1.to_s + ' < Desvio <= ' + limiteg5_2.to_s
        posicion3_name = limiteg5_2.to_s + ' < Desvio <= ' + limiteg5_3.to_s
        posicion4_name = limiteg5_3.to_s + ' < Desvio <= ' + limiteg5_4.to_s
        posicion5_name = limiteg5_4.to_s + ' < Desvio <= ' + limiteg5_5.to_s
        posicion6_name = 'Desvio > ' + limiteg5_5.to_s

        #Poner todo en 0, ahora mismo tiene valores porque es una prueba
        mapaG5[posicion1_name] = 0
        mapaG5[posicion2_name] = 0
        mapaG5[posicion3_name] = 0
        mapaG5[posicion4_name] = 0
        mapaG5[posicion5_name] = 0
        mapaG5[posicion6_name] = 0

        #Tabla resumen de desvio de plazos
        mediaArray = Array.new
        media = 0
        minimo = 0
        maximo = 0

        distanciaArrayTipica = Array.new
        distanciaTotal = 0
        tipica = 0

        guardarUnaVez = true

        issuesOts.each do |ot|
          issue_fields = obtenerValorDesvioOT(ot, issueCustomField, false)
          calculo = issue_fields.campo_calc_plazo

          if !calculo.nil?
            if guardarUnaVez
              minimo = calculo
              maximo = calculo
              guardarUnaVez = false
            end
            
            mediaArray.push(calculo)

            if calculo < minimo
              minimo = calculo
            end
            if calculo > maximo
              maximo = calculo
            end 

            key = posicion1_name
            if calculo > limiteg5_1.to_i && calculo <= limiteg5_2.to_i
              key = posicion2_name
            elsif calculo > limiteg5_2.to_i && calculo <= limiteg5_3.to_i
              key = posicion3_name
            elsif calculo > limiteg5_3.to_i && calculo <= limiteg5_4.to_i
              key = posicion4_name
            elsif calculo > limiteg5_4.to_i && calculo <= limiteg5_5.to_i
              key = posicion5_name
            elsif calculo > limiteg5_5.to_i
              key = posicion6_name
            end

            key = key
            if !mapaG5[key].nil?
              mapaG5[key] = 1 + mapaG5[key]
            else 
              mapaG5[key] = 1
            end

            fields_links = IndicatorsUtils::FieldsLinks.new
            if esSis
              fields_links.set_proy_ident($CONST_ID_PROJ)
            else
              fields_links.set_proy_ident(I18n.t("proy_sis_info").downcase)              
            end            
            #fields_links.set_estado(estadoPeticiong5n1.join("%7C"))
            fields_links.set_tipo(tipopeticiong5n1.id.to_s)
            idContrato = ot.custom_field_value(campoAgruparPorg5.id)
            idCampo = issueCustomField.id.to_s

            if idContrato != nil
              fields_links.set_contrato(idContrato)
            else
              fields_links.set_contrato('')
            end

            if idCampo != nil
              fields_links.set_id_cf_desvio(idCampo)
            else
              fields_links.set_id_cf_desvio('')
            end
            
            case key
            when posicion1_name
              fields_links.set_desvio(limiteg5_1.to_s)
            when posicion2_name
              fields_links.set_desvio(limiteg5_1.to_s+'%7C'+limiteg5_2.to_s)
            when posicion3_name
              fields_links.set_desvio(limiteg5_2.to_s+'%7C'+limiteg5_3.to_s)
            when posicion4_name
              fields_links.set_desvio(limiteg5_3.to_s+'%7C'+limiteg5_4.to_s)
            when posicion5_name
              fields_links.set_desvio(limiteg5_4.to_s+'%7C'+limiteg5_5.to_s)
            when posicion6_name
              fields_links.set_desvio(limiteg5_5.to_s)
            end

            if listaFieldsLinks[key] == nil
              #posicion 0
              cadena = fields_links.proy_ident + $SPLIT_CHAR
              #posicion 1
              #cadena = cadena + fields_links.estado + $SPLIT_CHAR
              #posicion 2
              cadena = cadena + fields_links.tipo + $SPLIT_CHAR              
              #posicion 3
              cadena = cadena + fields_links.id_cf_desvio + $SPLIT_CHAR
              #posicion 4
              cadena = cadena + fields_links.desvio + $SPLIT_CHAR
              #posicion 5
              cadena = cadena + fields_links.contrato
              listaFieldsLinks[key] = cadena
            else 
              listaFieldsLinks[key] = listaFieldsLinks[key] +'%7C'+ fields_links.contrato
            end
          end          
        end

        #Sacar la MEDIA y la DESVIACION TIPICA
        if !mediaArray.nil? && !mediaArray.empty?
          #Calculamos la media primeramente sumando los valores entre el total de valores
          mediaArray.each do |valor|
            media = valor + media
          end
          media = media / mediaArray.size

          #La informacion de desviacion tipica no se quiere mostrar por ahora
          #pero NO BORRAR, puede ser que sea necesaria mas adelante

          #Calculamos la distancia de cada valor restando la media y calculando su cuadrado 
          #y el resultado lo guardamos en un array para usar luego otro calculo
          #mediaArray.each do |valor|
          #  distancia = (valor - media)**2
          #  distanciaArrayTipica.push(distancia)
          #end

          #Calculamos la suma de los valores de distancia entre el total de valores que tenemos
          #distanciaArrayTipica.each do |valor|
          #  distanciaTotal = valor + distanciaTotal
          #end
          #distanciaTotal = distanciaTotal / mediaArray.size

          #Calculamos la raiz cuadrada de la distancia total y el resultado es la desviacion
          #tipica = distanciaTotal**0.5

          mapaG5_resumen['Media']= media
          mapaG5_resumen['Minima']= minimo
          mapaG5_resumen['Maxima']= maximo
          #mapaG5_resumen['Tipica (σ)']= tipica
        end
      else 
        Rails.logger.info('montarGraficaPlazosDesvios no se ha encontrado nada')
      end
      chart_view.set_fieldsLinksg5(listaFieldsLinks)
      chart_view.set_mapaG5(mapaG5)
      chart_view.set_mapaG5_resumen(mapaG5_resumen)
      linkActivado = settings.actLinkg2 != nil && settings.actLinkg2 == "true"
      Printers::Desvios.pintarPlazosDesvios(chart_view, linkActivado)
    end

    # Método que obtiene de la OT dada el valor de los campos de importe y fecha
    def self.obtenerValorDesvioOT(ot, issueCustomField, esImp)
      Rails.logger.debug('Dentro de obtenerValorDesvioOT.')
      campoCalculado = nil
      csValue = nil
      csValue = CustomValue.where('custom_field_id = ' + issueCustomField.id.to_s + ' and customized_id = ' + ot.id.to_s)[0]

      if !csValue.nil?
        campoCalculado = csValue.value.to_i
      end
      
      issue_fields = IndicatorsUtils::IssueFields.new
      if esImp
        issue_fields.set_campo_calc_importe(campoCalculado)   
      else
        issue_fields.set_campo_calc_plazo(campoCalculado)
      end
      return issue_fields
    end
  end
end