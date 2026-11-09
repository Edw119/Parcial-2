defmodule Reporte do

  # Generar el reporte completo
  def generar(ciudades, movimientos, rechazados_ciudades, rechazados_movimientos) do

    reporte_ciudades =
      Enum.map_join(ciudades, "\n\n", fn ciudad ->

        movimientos_ciudad =
          Enum.filter(movimientos, fn movimiento ->
            movimiento.id_ciudad == ciudad.id
          end)

        generar_reporte_ciudad(ciudad, movimientos_ciudad)

      end)

    reporte_final = """
    ==========================================
       OBSERVATORIO SISMOLOGICO
       UNIVERSIDAD DEL QUINDIO
    ==========================================

    #{reporte_ciudades}

    ==========================================
    REGISTROS RECHAZADOS
    ==========================================

    Ciudades: #{rechazados_ciudades}
    Movimientos: #{rechazados_movimientos}

    ==========================================
    """

    reporte_final

  end


  # Generar reporte de una ciudad
  defp generar_reporte_ciudad(ciudad, movimientos) do

    {cantidad, mayor, suma_profundidades} =
      calcular_estadisticas(movimientos)

    detalle =

      if cantidad == 0 do

        "Sin movimientos registrados"

      else

        Enum.map_join(movimientos, "\n", fn movimiento ->

          "Codigo: #{movimiento.codigo} | " <>
          "Inicio: #{movimiento.hora_inicio} | " <>
          "Final: #{movimiento.hora_final} | " <>
          "Magnitud: #{movimiento.magnitud} | " <>
          "Profundidad: #{movimiento.profundidad} km"

        end)

      end


    estadisticas =

      if cantidad == 0 do

        """
        Total de movimientos: 0
        Movimiento de mayor magnitud: No aplica
        Profundidad promedio: No aplica
        """

      else

        promedio =
          :erlang.float_to_binary(
            suma_profundidades / cantidad,
            decimals: 2
          )

        """
        Total de movimientos: #{cantidad}
        Movimiento de mayor magnitud: #{mayor.codigo} - #{mayor.magnitud}
        Profundidad promedio: #{promedio} km
        """

      end


    """
    ------------------------------------------
    Ciudad: #{ciudad.nombre}
    ID: #{ciudad.id}
    Numero de habitantes: #{ciudad.habitantes}

    MOVIMIENTOS:
    #{detalle}

    ESTADISTICAS:
    #{estadisticas}
    ------------------------------------------
    """

  end


  # Calcular las estadisticas mediante recursividad
  defp calcular_estadisticas(movimientos) do

    calcular_estadisticas(movimientos, 0, nil, 0.0)

  end


  # Caso base
  defp calcular_estadisticas([], cantidad, mayor, suma) do

    {cantidad, mayor, suma}

  end


  # Caso recursivo
  defp calcular_estadisticas(
    [movimiento | resto],
    cantidad,
    mayor,
    suma
  ) do

    nuevo_mayor =

      if mayor == nil or movimiento.magnitud > mayor.magnitud do

        movimiento

      else

        mayor

      end

    calcular_estadisticas(
      resto,
      cantidad + 1,
      nuevo_mayor,
      suma + movimiento.profundidad
    )

  end

  # Generar el reporte de una sola ciudad
def generar_reporte_individual(ciudad, movimientos) do

  generar_reporte_ciudad(ciudad, movimientos)

end

end
