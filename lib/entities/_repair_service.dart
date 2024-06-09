class Service {
  final String id; // Nuevo campo id
  final String nombre;
  final double precio;
  final String descripcion;
  final Tamanio tamanio;
 
  Service({required this.nombre, required this.precio, required this.descripcion, required this.tamanio, required this.id});

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      nombre: map['nombre'] ?? '',
      precio: map['precio'] ?? 0.0,
      descripcion: map['descripcion'] ?? '',
      tamanio: Tamanio.values[map['tamanio'] ?? 0], id: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'precio': precio,
      'descripcion': descripcion,
      'tamanio': tamanio.index,
    };
  }

}

enum Tamanio {
  chico,
  grande,
}

List<Service> services = [
  Service(
    id: '1', // ID del servicio 1
    nombre: 'pintra',
    precio: 30000,
    descripcion: 'nueva capa de pintura para todo el vehiculo',
    tamanio: Tamanio.grande,
  ),
  Service(
    id: '2', // ID del servicio 2
    nombre: 'pulido',
    precio: 15000,
    descripcion: 'pulido para todo el vehiculo',
    tamanio: Tamanio.chico,
  ),
];
