module Printers
  class ImportesEjecutados
    # Método que pinta la gráfica de importes ejecutados
    def self.pintarImportesEjecutados(chart_view)
      Rails.logger.info('Dentro de pintarImportesEjecutados.')
      mapaG2 = chart_view.mapaG2
      mapaG2_OTs_contrato = Hash.new
      anchoBarra = 40

      chartG2 = LazyHighCharts::HighChart.new('chartG2') do |f|
        f.legend(false)
        if chart_view.procedencia == 'indicadores'
          f.chart({defaultSeriesType: "column", width: 900})
          f.legend(align: 'right', verticalAlign: 'top', y: 30, x: 0, layout: 'vertical')          
        else
          f.legend(align: 'center', verticalAlign: 'bottom', y: 10, x: 0, layout: 'vertical')
          f.chart({defaultSeriesType: "column", height: 300})
        end
        f.exporting(false)
        f.title(text: I18n.t('title_g2'))
        f.tooltip(false)
        f.xAxis(categories: mapaG2.keys)
        arrayData = Array.new
        
        mapaG2.each do |key, importe|          
          arrayMap = Array.new
          arrayMap.push(key)
          arrayMap.push(importe)
          arrayData.push(arrayMap)
        end
        f.series(name: I18n.t('field_legend_info_1'), data: arrayData, pointWidth: anchoBarra)
        f.plotOptions(series: {:point => {:events => {click: 'click_functionIE'}}})
      end
      chart_view.set_chartG2(chartG2)
      chart_view.set_mostrarCuadro(true)
    end

    def self.pintarImportesEjecutadosStacked(chart_view, mostrarLeyenda, enlacesActivos, whereProject)
      Rails.logger.info('Dentro de pintarImportesEjecutadosStacked.')
      mapaG2 = chart_view.mapaG2
      mapaG2_OTs_contrato = Hash.new
      
      activarLeyenda = mostrarLeyenda != nil && mostrarLeyenda == "true"
      pagProcedencia = chart_view.procedencia

      anchoBarra = 80

      chartG2 = LazyHighCharts::HighChart.new('chartG2') do |f|
        f.legend(enabled: activarLeyenda)
        if pagProcedencia == 'indicadores'
          f.chart({defaultSeriesType: "column", width: 1000, height: 600})
          if activarLeyenda
            f.legend(align: 'center', verticalAlign: 'top', y: 20, x: 0, layout: 'vertical')
          end
        else
          anchoBarra = 60 
          f.chart({defaultSeriesType: "column", height: 300})
          if activarLeyenda
            f.legend(align: 'center', verticalAlign: 'bottom', y: 10, x: 0, layout: 'vertical')
          end
        end
        f.exporting(false)
        f.title(text: I18n.t('title_g2'))
        f.tooltip(headerFormat: '<b>{point.x}</b><br/>', 
          pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}')

        anyos = Array.new
        mapaG2.each do |key, mapa|
          mapa.each do |anyo, dato|
            unless anyos.include? anyo
              anyos.push(anyo)
            end
          end
        end
        anyos = anyos.sort
        f.xAxis(categories: anyos)
        f.yAxis(title: {text: ''},stackLabels: {enabled: true, style: {fontWeight: 'bold'}}) 
    
        mapaG2.each do |key, mapa|
          arrayDato = Array.new(anyos.size, nil)
          mapa.each do |anyo, dato|
            arrayDato[anyos.index(anyo)] = dato
          end
          f.series(name: key, data: arrayDato, pointWidth: anchoBarra)
        end

        if pagProcedencia == 'indicadores' && enlacesActivos     
          f.plotOptions({series: {:point => {:events => {click: 'click_functionSTACK'}}, :cursor => 'pointer'}, :column => {:stacking => 'normal', :dataLabels => {:enabled => false}}})        
        else
          f.plotOptions({series: {:point => {:events => {click: 'click_functionSTACK'}}}, :column => {:stacking => 'normal', :dataLabels => {:enabled => false}}})
        end
      end

      chart_view.set_chartG2(chartG2)
      chart_view.set_mostrarCuadro(false)      
    end

    def self.pintarImpEjecContStacked(chart_view, mostrarLeyenda, enlacesActivos, whereProject)
      Rails.logger.info('Dentro de pintarImpEjecContStacked.')
      mapaG2 = chart_view.mapaG2
      mapaG2_OTs_contrato = Hash.new
      anchoBarra = 80
      pagProcedencia = chart_view.procedencia

      chartG2 = LazyHighCharts::HighChart.new('chartG2') do |f|
        f.legend(enabled: true)
        if pagProcedencia == 'indicadores'
          f.chart({defaultSeriesType: "column", width: 900, height: 600})          
          f.legend(align: 'center', verticalAlign: 'top', y: 20, x: 0, layout: 'vertical')
        else
          anchoBarra = 60 
          f.chart({defaultSeriesType: "column", height: 300})
          f.legend(align: 'center', verticalAlign: 'bottom', y: 10, x: 0, layout: 'vertical')
        end
        f.exporting(false)
        f.title(text: I18n.t('title_g2'))
        f.tooltip(headerFormat: '<b>{point.x}</b><br/>', 
          pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}')

        anyos = Array.new
        mapaG2.each do |key, mapa|
          mapa.each do |anyo, dato|
            unless anyos.include? anyo
              anyos.push(anyo)
            end
          end
        end
        anyos = anyos.sort
        f.xAxis(categories: anyos)
        f.yAxis(title: {text: ''},stackLabels: {enabled: true, style: {fontWeight: 'bold'}}) 
    
        mapaG2.each do |key, mapa|
          arrayDato = Array.new(anyos.size, nil)
          mapa.each do |anyo, dato|            
            arrayDato[anyos.index(anyo)] = dato
          end
          f.series(name: key, data: arrayDato, pointWidth: anchoBarra)
        end

        if pagProcedencia == 'indicadores' && enlacesActivos     
          f.plotOptions({series: {:point => {:events => {click: 'click_functionSTACK2'}}, :cursor => 'pointer'}, :column => {:stacking => 'normal', :dataLabels => {:enabled => false}}})        
        else
          f.plotOptions({series: {:point => {:events => {click: 'click_functionSTACK2'}}}, :column => {:stacking => 'normal', :dataLabels => {:enabled => false}}})
        end
      end

      chart_view.set_chartG2(chartG2)
      chart_view.set_mostrarCuadro(false)      
    end
  end
end