Parcial 2 - Programación 3

Universidad del Quindío

Punto 1 - Reporte local

Ejecución del programa

Para ejecutar el punto 1, abrir una terminal de PowerShell y ubicarse en la carpeta Punto1, donde se encuentra el archivo programa.exs.

Comando:

elixir programa.exs

Archivos de entrada

Los archivos utilizados para generar el reporte se encuentran en la siguiente ubicación:

Punto1/resources/
├── ciudades.txt
└── movimientos.txt

ciudades.txt: contiene los identificadores, nombres y número de habitantes de las ciudades.

movimientos.txt: contiene los códigos, ciudades asociadas, horas, magnitudes y profundidades de los movimientos sísmicos.

Archivo de salida

El programa genera el reporte y lo guarda en:

Punto1/resources/reporte_sismos.txt

Este archivo contiene la información de las ciudades, sus movimientos sísmicos, las estadísticas y la cantidad de registros rechazados.

Punto 2 - Consulta entre nodos

Para ejecutar este punto se necesitan dos terminales de PowerShell. Primero se inicia el servidor y después se ejecuta el cliente.

1. Iniciar el servidor

Abrir la primera terminal y ubicarse en la carpeta:

Punto2/nodo-servidor

Ejecutar el siguiente comando:

elixir --name servidor@127.0.0.1 --cookie sismos123 servidor.exs

El servidor debe mostrar:

SERVIDOR SISMOLOGICO INICIADO
Esperando solicitudes de los clientes...

Se debe dejar esta terminal abierta, ya que el servidor necesita permanecer activo para atender las solicitudes del cliente.

2. Iniciar el cliente

Abrir una segunda terminal de PowerShell y ubicarse en la carpeta:

Punto2/nodo-cliente

Ejecutar el siguiente comando:

elixir --name cliente@127.0.0.1 --cookie sismos123 cliente.exs

El cliente se conecta al nodo servidor mediante Node.connect/1 y envía las solicitudes correspondientes.

3. Configuración de los nodos

Los nodos utilizados son:

Elemento                             Configuración

Nodo servidor                        servidor@127.0.0.1

Nodo cliente                         cliente@127.0.0.1

Cookie compartida                    sismos123

Proceso registrado en el servidor    :servicio_sismos

Proceso registrado en el cliente     :servicio_respuesta

Ambos nodos deben utilizar exactamente la misma cookie para permitir la comunicación.

Verificación del punto 2

Para comprobar el funcionamiento del sistema se utilizaron los siguientes identificadores de ciudades:

Identificador       Ciudad             Caso de prueba

C01                 Armenia            Ciudad con movimientos sísmicos

C03                 Circasia           Ciudad sin movimientos sísmicos

C99                 No registrada      Ciudad inexistente

El cliente envía las siguientes solicitudes al servidor:

{:reporte_ciudad, "C01"}: consulta el reporte de Armenia.

{:reporte_ciudad, "C03"}: consulta el reporte de Circasia.

{:reporte_ciudad, "C99"}: consulta una ciudad inexistente.

:reporte_general: solicita el reporte de todas las ciudades.

:fin: finaliza las consultas del cliente.

Comprobar que el servidor sigue funcionando

Después de ejecutar el cliente por primera vez, el servidor debe permanecer activo.

Para comprobarlo, sin cerrar la terminal del servidor, se debe abrir una nueva terminal en la carpeta Punto2/nodo-cliente y ejecutar nuevamente:

elixir --name cliente@127.0.0.1 --cookie sismos123 cliente.exs

El cliente debe conectarse nuevamente y recibir las respuestas del servidor.

De esta manera se comprueba que el servidor continúa atendiendo solicitudes después de que un cliente finaliza sus consultas.

Reflexión sobre el uso de inteligencia artificial

Durante el desarrollo del parcial se utilizó ChatGPT como herramienta de apoyo para comprender conceptos de Elixir, resolver dudas sobre programación concurrente, comunicación entre nodos y corregir errores de ejecución.

Las sugerencias recibidas fueron revisadas, adaptadas y probadas en el proyecto para comprobar su funcionamiento.

1. Herramientas y agentes

Se utilizó ChatGPT para:

Comprender el uso de estructuras (structs) para representar ciudades y movimientos sísmicos.

Resolver dudas sobre lectura y validación de archivos.

Comprender el funcionamiento de spawn, send y receive.

Orientar la comunicación entre el cliente y el servidor mediante nodos.

Identificar y corregir errores durante las pruebas.

2. Caso decisivo

Durante la ejecución del punto 2 apareció un error de conexión entre el cliente y el servidor.

Al consultar el problema, se identificó que el proceso principal del servidor terminaba después de registrar el proceso encargado de recibir las solicitudes.

Como solución se agregó un bloque receive en la función main del servidor para mantener activo el nodo.

Después de aplicar el cambio y ejecutar nuevamente ambos programas, se comprobó que el cliente lograba conectarse y recibir las respuestas del servidor.

4. Conclusiones

El desarrollo del parcial permitió comprender mejor el uso de estructuras, recursividad, lectura de archivos y programación concurrente en Elixir.

Se logró implementar la comunicación entre nodos y realizar consultas desde un cliente hacia un servidor.

Uno de los temas que todavía presenta dificultad es la comunicación distribuida y el manejo de los procesos cuando se presentan errores.

Para un próximo proyecto sería conveniente realizar pruebas más pequeñas desde el inicio, organizar mejor los módulos y profundizar en el funcionamiento de los procesos y los mensajes en Elixir.