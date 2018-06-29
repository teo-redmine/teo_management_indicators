module Printers
  class SectoresContratos
    # Método que pinta la gráfica de actuaciones issues
    def self.pintarSectoresContratos(chart_view, enlacesActivos)
      Rails.logger.info('Dentro de pintarSectoresContratos.')
      mapaG3 = chart_view.mapaG3
      chartG3 = LazyHighCharts::HighChart.new('chartG3') do |f|    
        f.chart({plotBackgroundColor: nil, plotBorderWidth: nil, plotShadow: false, type: 'pie', width: 600})
        f.legend(align: 'right', verticalAlign: 'top', y: 30, x: 0, layout: 'vertical')
        f.tooltip(false)
        f.title(text: I18n.t('title_g3'))
        f.exporting(false)
        f.xAxis(categories: [""])

        #Calcular porcentajes de los valores que tengo total y independientes, para mostrar
        importeTotal = 0
        mapaG3.each do |key, importe|          
          importeTotal = importeTotal + importe
        end

        arrayData = Array.new
        mapaG3.each do |key, importe|          
          arrayMap = Array.new
          arrayMap.push(key.split($SPLIT_CHAR)[0])
          arrayMap.push((importe*100)/importeTotal)
          arrayData.push(arrayMap)
        end

        f.series(name: "Brands", data: arrayData, colorByPoint: true)
        if enlacesActivos
          f.plotOptions(series: {:point => {:events => {click: 'click_functionSC'}}, :cursor => 'pointer'})
        else
          f.plotOptions(series: {:point => {:events => {click: 'click_functionSC'}}})
        end        
      end

      chart_view.set_chartG3(chartG3)
      chart_view.set_mostrarCuadro(true)
    end
  end
end