module Printers
  class ActuacionesEnCurso
    # Método que pinta la gráfica de actuaciones en curso
    def self.pintarActuacionesEnCurso(chart_view, mapaPorcentajesImportes, enlacesActivos)
      Rails.logger.info('Dentro de pintarActuacionesEnCurso.')
      stackG1a = LazyHighCharts::HighChart.new('stackG1a') do |f|
        pointWidth = 60
        if chart_view.procedencia == 'indicadores'
          f.chart({defaultSeriesType: "bar", height: 175, width: 700})
          f.legend(align: 'right', verticalAlign: 'top', y: 30, x: -50, layout: 'vertical', reversed: true)
          f.tooltip(false)
          f.title(text: I18n.t('title_g1'))        
        else
          f.chart({defaultSeriesType: "bar", height: 100})
          f.legend(false)
          f.tooltip(useHTML: true, headerFormat: '<small>{point.key}</small><table>', pointFormat: '<tr><td style="color: {series.color}">{series.name}: </td>' + '<td style="text-align: right"><b>{point.y} %</b></td></tr>', footerFormat: '</table>')
          f.title(text: I18n.t('title_g1'))
        end
        f.exporting(false)
        f.xAxis(categories: [""])
        plotLines = Array.new
        
        if !mapaPorcentajesImportes.nil? && mapaPorcentajesImportes.any?
          cont = 0

          numericKeys = Array.new
          for key in mapaPorcentajesImportes.keys
            begin
              Float(key)
              numericKeys.push(key)
            rescue Exception => e
              Rails.logger.error('id no numérico: ' + key)
            end
          end
          isSt = IssueStatus.find_by_sql(['SELECT `issue_statuses`.* FROM `issue_statuses` WHERE `issue_statuses`.`id` IN (?)', numericKeys])

          mapaPorcentajesImportes.each do |key, porcentajeEstado|
            if (porcentajeEstado).round(0) > 0
              if key != nil && key == "Disponible"
                f.series(name: I18n.t('field_available'), data: [(porcentajeEstado).round(0)], color: IndicatorsUtils::Colors.colorDisponible, pointWidth: pointWidth)
              elsif key != nil && key == "En curso-realizado"
                f.series(name: I18n.t('field_completed'), data: [(porcentajeEstado).round(0)], color: IndicatorsUtils::Colors.colorEnCursoRealizado, pointWidth: pointWidth)
              else
                if !isSt.nil? && isSt.any?
                  for isStAux in isSt
                    if isStAux.id == key
                      if cont < 4
                        f.series(name: I18n.t("field_" + isStAux.to_s), data: [(porcentajeEstado).round(0)], color: IndicatorsUtils::Colors.colores[cont], pointWidth: pointWidth)
                      else
                        f.series(name: I18n.t("field_" + isStAux.to_s), data: [(porcentajeEstado).round(0)], pointWidth: pointWidth)
                      end
                    end
                  end
                end

                cont += 1
              end
            end
          end
        else
          f.series(name: I18n.t('field_available'), data: [100], color: IndicatorsUtils::Colors.colorDisponible, pointWidth: pointWidth)
        end

        if chart_view.procedencia == 'indicadores' && enlacesActivos
          f.plotOptions(series: {:point => {:events => {click: 'click_functionAC'}}, :cursor => 'pointer'}, :bar => {stacking: "percent", :dataLabels => {format: "{y}%", enabled: true, :style => {color: "#FFFFFF", fontWeight: "bold"}}})
        else
          f.plotOptions(series: {:point => {:events => {click: 'click_functionAC'}}}, :bar => {stacking: "percent", :dataLabels => {format: "{y}%", enabled: true, :style => {color: "#FFFFFF", fontWeight: "bold"}}})
        end
      end

      chart_view.set_stackG1a(stackG1a)
    end
  end
end