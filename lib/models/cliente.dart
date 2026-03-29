class Cliente {
  final String  id;
  final String  nombre;
  final String  apellidos;
  final String  telefono;
  final String? email;
  final String? notas;
  final DateTime createdAt;

  Cliente({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
    this.email,
    this.notas,
    required this.createdAt,
  });

  // Convierte Map de Json que tomamos de Supabase en un objeto Cliente
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id:        json['id']        as String,
      nombre:    json['nombre']    as String,
      apellidos: json['apellidos'] as String,
      telefono:  json['telefono']  as String,
      email:     json['email']     as String?,
      notas:     json['notas']     as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convierte un objeto Cliente en Map de Json que necesita recibir Supabase
  Map<String, dynamic> toJson() {
    return {
      'nombre':    nombre,
      'apellidos': apellidos,
      'telefono':  telefono,
      'email':     email,
      'notas':     notas,
    };
  }

  // Para realizar copia del cliente con campos modificados sin tocar el resto en el formulario de edición

  Cliente copyWith({
    String? nombre,
    String? apellidos,
    String? telefono,
    String? email,
    String? notas,
  }) {
    return Cliente(
      id:        id,
      nombre:    nombre    ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      telefono:  telefono  ?? this.telefono,
      email:     email     ?? this.email,
      notas:     notas     ?? this.notas,
      createdAt: createdAt,
    );
  }

  // Getter para mostrar nombre si tener que repetir las variables cada vez
  String get nombreCompleto => '$nombre $apellidos';
}