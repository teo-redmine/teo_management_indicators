module Printers
  class TiempoTranscurrido
    # Método que pinta la gráfica de tiempo transcurrido
    def self.pintarTiempoTranscurrido(chart_view)
      Rails.logger.info('Dentro de pintarTiempoTranscurrido.')
      porcentajeDiasTranscurridos = chart_view.porcentajeDiasTranscurridos
      stackG1b = LazyHighCharts::HighChart.new('stackG1b') do |f|
        pointWidth = 20
        if chart_view.procedencia == 'indicadores'
          f.chart({defaultSeriesType: "bar", height: 100, width: 533})
        else
          f.chart({defaultSeriesType: "bar", height: 95})
        end
        f.legend(false)
        f.tooltip(false)
        f.exporting(false)
        f.title(text: I18n.t('title_g1b'))
        f.xAxis(categories: [""])
        f.plot_options({bar: {stacking: "percent", dataLabels: {y: 0, format: "{percentage}%", enabled: true, style: {color: "#FFFFFF", fontWeight: "bold"}}, grouping: false, shadow: false, borderWidth: 0, borderColor: "grey"}})

        if porcentajeDiasTranscurridos != nil
          if porcentajeDiasTranscurridos < 100
            f.series(name: I18n.t('field_available'), data: [100 - porcentajeDiasTranscurridos], color: "grey", pointWidth: pointWidth)
          end
          f.series(name: I18n.t('field_passed'), data: [porcentajeDiasTranscurridos], color: "black", pointWidth: pointWidth)
        end
      end

      chart_view.set_stackG1b(stackG1b)
    end
  end
end