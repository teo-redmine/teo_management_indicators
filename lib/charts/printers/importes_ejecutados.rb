module Printers
  class ImportesEjecutados
    # Método que pinta la gráfica de importes ejecutados
    def self.pintarImportesEjecutados(chart_view)
      Rails.logger.info('Dentro de pintarImportesEjecutados.')
      mapaG2 = chart_view.mapaG2
      chartG2 = LazyHighCharts::HighChart.new('chartG2') do |f|
        if chart_view.procedencia == 'indicadores'
          f.chart({defaultSeriesType: "column", width: 900})
        else
          f.chart({defaultSeriesType: "column", height: 200})
        end
        f.legend(align: 'right', verticalAlign: 'top', y: 30, x: 0, layout: 'vertical')
        f.tooltip(false)
        f.exporting(false)
        f.title(text: I18n.t('title_g2'))
        f.xAxis(categories: mapaG2.keys)

        arrayData = Array.new

        mapaG2.each do |key, importe|
          arrayMap = Array.new
          arrayMap.push(key)
          arrayMap.push(importe)
          arrayData.push(arrayMap)
        end

        f.series(name: I18n.t('field_legend_info_1'), data: arrayData, pointWidth: 40)
      end

      chart_view.set_chartG2(chartG2)
    end
  end
end