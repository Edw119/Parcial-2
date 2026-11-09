# Cargar los módulos
Code.require_file("ciudad.exs", __DIR__)

Code.require_file("movimiento.exs", __DIR__)

Code.require_file("lector.exs", __DIR__)

Code.require_file("reporte.exs", __DIR__)

Code.require_file("coordinador.exs", __DIR__)


# Ejecutar el programa principal
Coordinador.main()
