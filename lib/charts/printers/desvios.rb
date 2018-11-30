module Printers
  class Desvios
    def self.pintarImportesDesvios(chart_view, enlacesActivos)
      Rails.logger.info('Dentro de pintarImportesDesvios.')
      mapaG4 = chart_view.mapaG4      

      chartG4 = LazyHighCharts::HighChart.new('chartG4') do |f|
        f.chart({defaultSeriesType: "column", width: 900})
        f.legend(align: 'center', verticalAlign: 'top', y: 30, x: 0, layout: 'vertical')          
        f.exporting(false)
        f.title(text: I18n.t('title_g4'))
        f.tooltip(false)
        f.xAxis(categories: mapaG4.keys)

        arrayData = Array.new        
        mapaG4.each do |key, importe|          
          arrayMap = Array.new
          arrayMap.push(key)
          arrayMap.push(importe)
          arrayData.push(arrayMap)
        end
        f.series(name: I18n.t('field_legend_info_g4_5'), data: arrayData, pointPadding: 0, groupPadding: 0, borderWidth: 1, shadow: false)

        if enlacesActivos     
          f.plotOptions({series: {:point => {:events => {click: 'click_functionDesvioImp'}}, :cursor => 'pointer'}, :column => {:stacking => 'normal', :dataLabels => {:enabled => false}}})        
        else
          f.plotOptions({series: {:point => {:events => {click: 'click_functionDesvioImp'}}}, :column => {:stacking => 'normal', :dataLabels => {:enabled => false}}})
        end
      end
      chart_view.set_chartG4(chartG4)
      chart_view.set_mostrarCuadro(true)
    end

    def self.pintarPlazosDesvios(chart_view, enlacesActivos)
      Rails.logger.info('Dentro de pintarPlazosDesvios.')
      mapaG5 = chart_view.mapaG5

      chartG5 = LazyHighCharts::HighChart.new('chartG5') do |f|
        f.chart({defaultSeriesType: "column", width: 900})
        f.legend(align: 'center', verticalAlign: 'top', y: 30, x: 0, layout: 'vertical')          
        f.exporting(false)
        f.title(text: I18n.t('title_g5'))
        f.tooltip(false)
        f.xAxis(categories: mapaG5.keys)

        arrayData = Array.new        
        mapaG5.each do |key, importe|          
          arrayMap = Array.new
          arrayMap.push(key)
          arrayMap.push(importe)
          arrayData.push(arrayMap)
        end
        f.series(name: I18n.t('field_legend_info_g4_5'), data: arrayData, color: '#FF0000', pointPadding: 0, groupPadding: 0, borderWidth: 1, shadow: false)

        if enlacesActivos     
          f.plotOptions({series: {:point => {:events => {click: 'click_functionDesvioPlaz'}}, :cursor => 'pointer'}, :column => {:stacking => 'normal', :dataLabels => {:enabled => false}}})        
        else
          f.plotOptions({series: {:point => {:events => {click: 'click_functionDesvioPlaz'}}}, :column => {:stacking => 'normal', :dataLabels => {:enabled => false}}})
        end
      end
      chart_view.set_chartG5(chartG5)
      chart_view.set_mostrarCuadro(true)
    end
  end
end