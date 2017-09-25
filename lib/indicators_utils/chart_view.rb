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
  end
end
