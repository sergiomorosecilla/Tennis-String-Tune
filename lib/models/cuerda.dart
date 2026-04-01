class Cuerda {
  final String  id;
  final String  nombre;
  final String  marca;
  final double  precioUnitario;
  final bool    activo;
  final DateTime createdAt;

  Cuerda({
    required this.id,
    required this.nombre,
    required this.marca,
    required this.precioUnitario,
    required this.activo,
    required this.createdAt,
  });

  factory Cuerda.fromJson(Map<String, dynamic> json) {
    return Cuerda(
      id:             json['id']              as String,
      nombre:         json['nombre']          as String,
      marca:          json['marca']           as String,
      precioUnitario: (json['precio_unitario'] as num).toDouble(),
      activo:         json['activo']          as bool,
      createdAt:      DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre':          nombre,
      'marca':           marca,
      'precio_unitario': precioUnitario,
      'activo':          activo,
    };
  }

  Cuerda copyWith({
    String? nombre,
    String? marca,
    double? precioUnitario,
    bool?   activo,
  }) {
    return Cuerda(
      id:             id,
      nombre:         nombre         ?? this.nombre,
      marca:          marca          ?? this.marca,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      activo:         activo         ?? this.activo,
      createdAt:      createdAt,
    );
  }

  // Helper para mostrar precio formateado
  String get precioDisplay => '${precioUnitario.toStringAsFixed(2)} €';

  // Nombre completo para mostrar en selectores
  String get nombreCompleto => '$marca — $nombre';
}