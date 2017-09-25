module IndicatorsUtils
  class Colors
    COLOR_FACTURADO = "#3465A4"
    COLOR_CERRADO = "#0066CC"
    COLOR_RESUELTO = "#729FCF"
    COLOR_EN_CURSO = "#83CAFF"
    COLOR_DISPONIBLE = "#AEA79F"
    COLOR_EN_CURSO_REALIZADO = "#819BAF"

    class << self
      def colorFacturado
        COLOR_FACTURADO
      end

      def colorCerrado
        COLOR_CERRADO
      end

      def colorResuelto
        COLOR_RESUELTO
      end

      def colorEnCurso
        COLOR_EN_CURSO
      end

      def colorDisponible
        COLOR_DISPONIBLE
      end

      def colorEnCursoRealizado
        COLOR_EN_CURSO_REALIZADO
      end

      def colores
        colores = Array.new

        colores.push(colorEnCurso)
        colores.push(colorResuelto)
        colores.push(colorCerrado)
        colores.push(colorFacturado)

        return colores
      end
    end
  end
end
