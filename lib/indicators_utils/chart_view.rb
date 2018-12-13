module IndicatorsUtils
  class ChartView
    def set_procedencia(procedencia)
      @procedencia = procedencia
    end

    def procedencia
      @procedencia
    end

    def set_acsG1(acsG1)
      @acsG1 = acsG1
    end

    def acsG1
      @acsG1
    end

    def set_mapaG2(mapaG2)
      @mapaG2 = mapaG2
    end

    def mapaG2
      @mapaG2
    end

    def set_stackG1a(stackG1a)
      @stackG1a = stackG1a
    end

    def stackG1a
      @stackG1a
    end

    def set_stackG1b(stackG1b)
      @stackG1b = stackG1b
    end

    def stackG1b
      @stackG1b
    end

    def set_chartG2(chartG2)
      @chartG2 = chartG2
    end

    def chartG2
      @chartG2
    end

    def set_mapaTablaG1(mapaTablaG1)
      @mapaTablaG1 = mapaTablaG1
    end

    def mapaTablaG1
      @mapaTablaG1
    end

    def set_importeAcumuladoG1(importeAcumuladoG1)
      @importeAcumuladoG1 = importeAcumuladoG1
    end

    def importeAcumuladoG1
      @importeAcumuladoG1
    end

    def set_porcentajeAcumuladoG1(porcentajeAcumuladoG1)
      @porcentajeAcumuladoG1 = porcentajeAcumuladoG1
    end

    def porcentajeAcumuladoG1
      @porcentajeAcumuladoG1
    end

    def set_fechaInicio(fechaInicio)
      @fechaInicio = fechaInicio
    end

    def fechaInicio
      @fechaInicio
    end

    def set_fechaFin(fechaFin)
      @fechaFin = fechaFin
    end

    def fechaFin
      @fechaFin
    end

    def set_fechaHoy(fechaHoy)
      @fechaHoy = fechaHoy
    end

    def fechaHoy
      @fechaHoy
    end

    def diasTotales
      if self.fechaFin != nil && self.fechaFin != '' && self.fechaInicio != nil && self.fechaInicio != ''
        @diasTotales = (self.fechaFin - self.fechaInicio).to_i
      end
      @diasTotales
    end

    def diasTranscurridos
      if self.fechaHoy != nil && self.fechaInicio != nil && self.fechaHoy != '' && self.fechaInicio != ''
        @diasTranscurridos = (self.fechaHoy - self.fechaInicio).to_i
      end
      @diasTranscurridos
    end

    def porcentajeDiasTranscurridos
      if self.diasTotales != nil && self.diasTotales != 0 && self.diasTranscurridos != nil && self.diasTranscurridos != 0
        @porcentajeDiasTranscurridos = self.diasTranscurridos * 100 / self.diasTotales
      end
      @porcentajeDiasTranscurridos
    end

    def set_mostrarCuadro(mostrar)
      @mostrarCuadro = mostrar
    end

    def mostrarCuadro
      @mostrarCuadro
    end

    def set_mostrarActualizar(mostrarActualizar)
      @mostrarActualizar = mostrarActualizar
    end

    def mostrarActualizar
      @mostrarActualizar
    end

    def set_mapaG3(mapaG3)
      @mapaG3 = mapaG3
    end

    def mapaG3
      @mapaG3
    end

    def set_chartG3(chartG3)
      @chartG3 = chartG3
    end

    def chartG3
      @chartG3
    end

    def set_mapaG1LinksProy(mapaG1LinksProy)
      @mapaG1LinksProy = mapaG1LinksProy
    end

    def mapaG1LinksProy
      @mapaG1LinksProy
    end

    def set_fieldsLinks(fieldsLinks)
      @fieldsLinks = fieldsLinks
    end

    def fieldsLinks
      @fieldsLinks
    end

    def set_fieldsLinksg4(fieldsLinksg4)
      @fieldsLinksg4 = fieldsLinksg4
    end

    def fieldsLinksg4
      @fieldsLinksg4
    end

    def set_fieldsLinksg5(fieldsLinksg5)
      @fieldsLinksg5 = fieldsLinksg5
    end

    def fieldsLinksg5
      @fieldsLinksg5
    end

    def set_fieldsSectores(fieldsSectores)
      @fieldsSectores = fieldsSectores
    end

    def fieldsSectores
      @fieldsSectores
    end

    def set_mensajeAC(mensajeAC)
      @mensajeAC = mensajeAC
    end

    def mensajeAC
      @mensajeAC
    end

    def set_mapaG4(mapaG4)
      @mapaG4 = mapaG4
    end

    def mapaG4
      @mapaG4
    end

    def set_chartG4(chartG4)
      @chartG4 = chartG4
    end

    def chartG4
      @chartG4
    end

    def set_mapaG4_resumen(mapaG4_resumen)
      @mapaG4_resumen = mapaG4_resumen
    end

    def mapaG4_resumen
      @mapaG4_resumen
    end

    def set_mapaG5_resumen(mapaG5_resumen)
      @mapaG5_resumen = mapaG5_resumen
    end

    def mapaG5_resumen
      @mapaG5_resumen
    end

    def set_mapaG5(mapaG5)
      @mapaG5 = mapaG5
    end

    def mapaG5
      @mapaG5
    end

    def set_chartG5(chartG5)
      @chartG5 = chartG5
    end

    def chartG5
      @chartG5
    end
  end
end
