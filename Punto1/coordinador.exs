defmodule Coordinador do

  def main do

    IO.puts("Iniciando generacion del reporte sismologico...")

    ruta_ciudades =
      Path.join(__DIR__, "resources/ciudades.txt")

    ruta_movimientos =
      Path.join(__DIR__, "resources/movimientos.txt")

    ruta_reporte =
      Path.join(__DIR__, "resources/reporte_sismos.txt")


    coordinador = self()


    # Proceso trabajador para leer ciudades
    spawn(fn ->

      resultado = Lector.leer_ciudades(ruta_ciudades)

      send(coordinador, {:ciudades, resultado})

    end)


    # Proceso trabajador para leer movimientos
    spawn(fn ->

      resultado = Lector.leer_movimientos(ruta_movimientos)

      send(coordinador, {:movimientos, resultado})

    end)


    # Esperar las respuestas de los trabajadores
    esperar_respuestas(2, nil, nil, ruta_reporte)

  end


  # Recibir las respuestas en cualquier orden
  defp esperar_respuestas(0, ciudades, movimientos, ruta_reporte) do

    procesar_resultados(ciudades, movimientos, ruta_reporte)

  end


  defp esperar_respuestas(restantes, ciudades, movimientos, ruta_reporte) do

    receive do

      {:ciudades, resultado} ->

        esperar_respuestas(
          restantes - 1,
          resultado,
          movimientos,
          ruta_reporte
        )


      {:movimientos, resultado} ->

        esperar_respuestas(
          restantes - 1,
          ciudades,
          resultado,
          ruta_reporte
        )

    end

  end


  # Procesar los resultados cuando ambos archivos se hayan leído
  defp procesar_resultados(
    {:ok, ciudades, rechazados_ciudades},
    {:ok, movimientos, rechazados_movimientos},
    ruta_reporte
  ) do

    # Obtener los identificadores de las ciudades validas
    ids_ciudades =
      ciudades
      |> Enum.map(fn ciudad -> ciudad.id end)
      |> MapSet.new()


    # Eliminar movimientos que tengan una ciudad inexistente
    movimientos_validos =
      Enum.filter(movimientos, fn movimiento ->

        MapSet.member?(ids_ciudades, movimiento.id_ciudad)

      end)


    # Contabilizar los movimientos rechazados por ciudad inexistente
    rechazados_movimientos =
      rechazados_movimientos +
      length(movimientos) - length(movimientos_validos)


    # Generar el reporte
    reporte = Reporte.generar(
      ciudades,
      movimientos_validos,
      rechazados_ciudades,
      rechazados_movimientos
    )


    # Mostrar el reporte en consola
    IO.puts(reporte)


    # Guardar el reporte en el archivo
    case File.write(ruta_reporte, reporte) do

      :ok ->

        IO.puts("Reporte guardado correctamente.")

      {:error, motivo} ->

        IO.puts("Error al guardar el reporte: #{inspect(motivo)}")

    end

  end


  # Si falla la lectura de alguno de los archivos
  defp procesar_resultados(ciudades, movimientos, _ruta_reporte) do

    case ciudades do

      {:error, mensaje} ->
        IO.puts(mensaje)

      _ ->
        :ok

    end


    case movimientos do

      {:error, mensaje} ->
        IO.puts(mensaje)

      _ ->
        :ok

    end

    IO.puts("No se pudo generar el reporte.")

  end

end
