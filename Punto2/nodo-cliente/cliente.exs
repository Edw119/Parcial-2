defmodule Cliente do

  def main do

    IO.puts("CLIENTE SISMOLOGICO")

    # Registrar el proceso que recibe las respuestas
    Process.register(self(), :servicio_respuesta)


    # Conectarse al nodo servidor
    nodo_servidor = :"servidor@127.0.0.1"

    case Node.connect(nodo_servidor) do

      true ->

        IO.puts("Conexion con el servidor exitosa.")

        enviar_solicitudes(nodo_servidor)

        recibir_respuestas()


      false ->

        IO.puts("Error: no fue posible conectar con el servidor.")


      :ignored ->

        IO.puts("Error: no fue posible establecer la conexion.")

    end

  end


  # Enviar las solicitudes al servidor
  def enviar_solicitudes(nodo_servidor) do

    destino = {:servicio_sismos, nodo_servidor}

    respuesta = {:servicio_respuesta, Node.self()}


    # 1. Ciudad con movimientos
    send(destino, {respuesta, {:reporte_ciudad, "C01"}})


    # 2. Ciudad sin movimientos
    send(destino, {respuesta, {:reporte_ciudad, "C03"}})


    # 3. Ciudad inexistente
    send(destino, {respuesta, {:reporte_ciudad, "C99"}})


    # 4. Reporte general
    send(destino, {respuesta, :reporte_general})


    # 5. Finalizar consultas
    send(destino, {respuesta, :fin})

    IO.puts("Solicitudes enviadas correctamente.")

  end


  # Recibir las respuestas del servidor
  def recibir_respuestas do

    receive do

      :fin ->

        IO.puts("\nEl servidor confirmo la finalizacion.")
        IO.puts("Cliente finalizado.")


      respuesta ->

        IO.puts("\n====================================")
        IO.puts("RESPUESTA DEL SERVIDOR")
        IO.puts("====================================")

        IO.puts(respuesta)

        recibir_respuestas()

    end

  end

end


# Ejecutar el cliente
Cliente.main()
