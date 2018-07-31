module Printers
  class ActuacionesIssues
    # Método que pinta la gráfica de actuaciones issues
    def self.pintarActuacionesIssues(chart_view)
      Rails.logger.info('Dentro de pintarActuacionesIssues.')
      mapaG1Ac = chart_view.mapaTablaG1
      stackG1a = LazyHighCharts::HighChart.new('stackG1a') do |f|
        pointWidth = 60       
        f.chart({defaultSeriesType: "bar", height: 175, width: 700, backgroundColor: '#FFD'})
        f.legend(align: 'right', verticalAlign: 'top', y: 30, x: -50, layout: 'vertical', reversed: true)
        f.tooltip(false)
        f.title(text: "")        
        f.exporting(false)
        f.xAxis(categories: [""])
        plotLines = Array.new
        
        mapaG1Ac.each do |key, mapa|
          colorBarra = IndicatorsUtils::Colors.colorDisponible
          case key    
          when "Nuevo"  
            colorBarra = IndicatorsUtils::Colors.colorNuevo
          when "En curso-realizado"
            colorBarra = IndicatorsUtils::Colors.colorEnCursoRealizado
          when "En curso"
            colorBarra = IndicatorsUtils::Colors.colorEnCurso
          when "Resuelto"
            colorBarra = IndicatorsUtils::Colors.colorResuelto
          when "Cerrado"
            colorBarra = IndicatorsUtils::Colors.colorCerrado
          when "Facturado"
            colorBarra = IndicatorsUtils::Colors.colorFacturado
          end          
          f.series(name: key, data: [mapa.round], color: colorBarra, pointWidth: pointWidth) 
        end

        f.plotOptions(series: {:point => {:events => {click: 'click_functionEA'}}, :cursor => 'pointer'}, :bar => {stacking: "percent", :dataLabels => {format: "{y}%", enabled: true, :style => {color: "#FFFFFF", fontWeight: "bold"}}})
      end

      chart_view.set_stackG1a(stackG1a)
      chart_view.set_mostrarCuadro(false)
    end
  end
end