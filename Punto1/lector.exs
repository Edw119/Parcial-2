defmodule Lector do

  # Leer archivo de ciudades
  def leer_ciudades(ruta) do

    case File.read(ruta) do

      {:ok, contenido} ->

        lineas = String.split(contenido, "\n")

        {ciudades, rechazados} =
          procesar_lineas(lineas, &crear_ciudad/1)

        {:ok, ciudades, rechazados}

      {:error, motivo} ->
        {:error, "Error al leer ciudades.txt: #{inspect(motivo)}"}

    end

  end


  # Leer archivo de movimientos
  def leer_movimientos(ruta) do

    case File.read(ruta) do

      {:ok, contenido} ->

        lineas = String.split(contenido, "\n")

        {movimientos, rechazados} =
          procesar_lineas(lineas, &crear_movimiento/1)

        {:ok, movimientos, rechazados}

      {:error, motivo} ->
        {:error, "Error al leer movimientos.txt: #{inspect(motivo)}"}

    end

  end


  # Procesar las líneas de los archivos
  defp procesar_lineas(lineas, funcion) do
    procesar_lineas(lineas, funcion, [], 0)
  end

  defp procesar_lineas([], _funcion, registros, rechazados) do
    {Enum.reverse(registros), rechazados}
  end

  defp procesar_lineas([linea | resto], funcion, registros, rechazados) do

    if String.trim(linea) == "" do

      procesar_lineas(resto, funcion, registros, rechazados)

    else

      case funcion.(linea) do

        {:ok, registro} ->

          procesar_lineas(
            resto,
            funcion,
            [registro | registros],
            rechazados
          )

        :error ->

          procesar_lineas(
            resto,
            funcion,
            registros,
            rechazados + 1
          )

      end

    end

  end


  # Crear una ciudad a partir de una línea
  defp crear_ciudad(linea) do

    campos =
      linea
      |> String.split("@", trim: false)
      |> Enum.map(&String.trim/1)

    case campos do

      [id, nombre, habitantes] ->

        if id != "" and nombre != "" do

          case Integer.parse(habitantes) do

            {numero, ""} when numero > 0 ->

              ciudad = %Ciudad{
                id: id,
                nombre: nombre,
                habitantes: numero
              }

              {:ok, ciudad}

            _ ->
              :error

          end

        else
          :error
        end

      _ ->
        :error

    end

  end


  # Crear un movimiento a partir de una línea
  defp crear_movimiento(linea) do

    campos =
      linea
      |> String.split("@", trim: false)
      |> Enum.map(&String.trim/1)

    case campos do

      [codigo, id_ciudad, hora_inicio, hora_final, magnitud, profundidad] ->

        if codigo != "" and id_ciudad != "" and
           hora_valida?(hora_inicio) and hora_valida?(hora_final) do

          case {Float.parse(magnitud), Float.parse(profundidad)} do

            {{mag, ""}, {prof, ""}} when prof >= 0 ->

              movimiento = %Movimiento{
                codigo: codigo,
                id_ciudad: id_ciudad,
                hora_inicio: hora_inicio,
                hora_final: hora_final,
                magnitud: mag,
                profundidad: prof
              }

              {:ok, movimiento}

            _ ->
              :error

          end

        else
          :error
        end

      _ ->
        :error

    end

  end


  # Validar que una hora tenga el formato HH:MM:SS
  defp hora_valida?(hora) do

    Regex.match?(~r/^\d{2}:\d{2}:\d{2}$/, hora) and
      match?({:ok, _}, Time.from_iso8601(hora))

  end

end
