
# Cargar los módulos necesarios
Code.require_file("ciudad.exs", __DIR__)
Code.require_file("movimiento.exs", __DIR__)
Code.require_file("lector.exs", __DIR__)
Code.require_file("reporte.exs", __DIR__)


defmodule Servidor do

  def main do

    IO.puts("SERVIDOR SISMOLOGICO INICIADO")

    # Registrar el proceso del servidor
    pid = spawn(fn -> atender_solicitudes() end)

    Process.register(pid, :servicio_sismos)

    IO.puts("Esperando solicitudes de los clientes...")

    # Mantener activo el nodo servidor
    receive do
      :detener_servidor ->
        IO.puts("Servidor finalizado.")
    end

  end


  # Esperar solicitudes de los clientes
  def atender_solicitudes do

    receive do

      {destino_respuesta, {:reporte_ciudad, id_ciudad}} ->

        IO.puts("Solicitud de reporte para ciudad: #{id_ciudad}")

        respuesta = generar_reporte_ciudad(id_ciudad)

        send(destino_respuesta, respuesta)

        atender_solicitudes()


      {destino_respuesta, :reporte_general} ->

        IO.puts("Solicitud de reporte general")

        respuesta = generar_reporte_general()

        send(destino_respuesta, respuesta)

        atender_solicitudes()


      {destino_respuesta, :fin} ->

        send(destino_respuesta, :fin)

        IO.puts("El cliente ha terminado sus consultas.")

        atender_solicitudes()

    end

  end


  # Generar reporte de una ciudad
  def generar_reporte_ciudad(id_ciudad) do

    case cargar_datos() do

      {:ok, ciudades, movimientos, _rc, _rm} ->

        case Enum.find(ciudades, fn ciudad ->
          ciudad.id == id_ciudad
        end) do

          nil ->

            "La ciudad no está registrada"

          ciudad ->

            movimientos_ciudad =
              Enum.filter(movimientos, fn movimiento ->
                movimiento.id_ciudad == id_ciudad
              end)

            Reporte.generar_reporte_individual(
              ciudad,
              movimientos_ciudad
            )

        end


      {:error, mensaje} ->

        mensaje

    end

  end


  # Generar reporte de todas las ciudades
  def generar_reporte_general do

    case cargar_datos() do

      {:ok, ciudades, movimientos, rc, rm} ->

        Reporte.generar(
          ciudades,
          movimientos,
          rc,
          rm
        )


      {:error, mensaje} ->

        mensaje

    end

  end


  # Leer los dos archivos concurrentemente
  def cargar_datos do

    ruta_ciudades =
      Path.join(__DIR__, "resources/ciudades.txt")

    ruta_movimientos =
      Path.join(__DIR__, "resources/movimientos.txt")

    coordinador = self()


    # Trabajador de ciudades
    spawn(fn ->

      resultado = Lector.leer_ciudades(ruta_ciudades)

      send(coordinador, {:ciudades, resultado})

    end)


    # Trabajador de movimientos
    spawn(fn ->

      resultado = Lector.leer_movimientos(ruta_movimientos)

      send(coordinador, {:movimientos, resultado})

    end)


    # Esperar los resultados
    esperar_resultados(2, nil, nil)

  end


  # Recibir resultados de los trabajadores
  defp esperar_resultados(0, ciudades, movimientos) do

    procesar_resultados(ciudades, movimientos)

  end


  defp esperar_resultados(restantes, ciudades, movimientos) do

    receive do

      {:ciudades, resultado} ->

        esperar_resultados(
          restantes - 1,
          resultado,
          movimientos
        )


      {:movimientos, resultado} ->

        esperar_resultados(
          restantes - 1,
          ciudades,
          resultado
        )

    end

  end


  # Verificar los resultados de lectura
  defp procesar_resultados(
    {:ok, ciudades, rc},
    {:ok, movimientos, rm}
  ) do

    ids_ciudades =
      Enum.map(ciudades, fn ciudad -> ciudad.id end)

    movimientos_validos =
      Enum.filter(movimientos, fn movimiento ->

        movimiento.id_ciudad in ids_ciudades

      end)

    rechazados =
      length(movimientos) - length(movimientos_validos)

    {:ok, ciudades, movimientos_validos, rc, rm + rechazados}

  end


  # Si ocurre un error al leer los archivos
  defp procesar_resultados(ciudades, movimientos) do

    case ciudades do

      {:error, mensaje} ->
        {:error, mensaje}

      _ ->

        case movimientos do

          {:error, mensaje} ->
            {:error, mensaje}

          _ ->
            {:error, "No se pudieron leer los archivos."}

        end

    end

  end

end


# Iniciar el servidor
Servidor.main()

