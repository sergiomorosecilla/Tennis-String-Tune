class Raqueta {
  final String  id;
  final String  clienteId;
  final String  marca;
  final String  modelo;
  final double? tensionHabitualMain;
  final double? tensionHabitualCross;
  final String? notas;
  final DateTime createdAt;

  Raqueta({
    required this.id,
    required this.clienteId,
    required this.marca,
    required this.modelo,
    this.tensionHabitualMain,
    this.tensionHabitualCross,
    this.notas,
    required this.createdAt,
  });

  factory Raqueta.fromJson(Map<String, dynamic> json) {
    return Raqueta(
      id:                   json['id']         as String,
      clienteId:            json['cliente_id'] as String,
      marca:                json['marca']      as String,
      modelo:               json['modelo']     as String,
      tensionHabitualMain:  (json['tension_habitual_main']  as num?)?.toDouble(),
      tensionHabitualCross: (json['tension_habitual_cross'] as num?)?.toDouble(),
      notas:                json['notas']      as String?,
      createdAt:            DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cliente_id':             clienteId,
      'marca':                  marca,
      'modelo':                 modelo,
      'tension_habitual_main':  tensionHabitualMain,
      'tension_habitual_cross': tensionHabitualCross,
      'notas':                  notas,
    };
  }

  Raqueta copyWith({
    String? marca,
    String? modelo,
    double? tensionHabitualMain,
    double? tensionHabitualCross,
    String? notas,
  }) {
    return Raqueta(
      id:                   id,
      clienteId:            clienteId,
      marca:                marca                ?? this.marca,
      modelo:               modelo               ?? this.modelo,
      tensionHabitualMain:  tensionHabitualMain  ?? this.tensionHabitualMain,
      tensionHabitualCross: tensionHabitualCross ?? this.tensionHabitualCross,
      notas:                notas                ?? this.notas,
      createdAt:            createdAt,
    );
  }

  // Helper para mostrar la tensión en formato legible
  String get tensionDisplay {
    if (tensionHabitualMain == null && tensionHabitualCross == null) {
      return 'Sin tensión registrada';
    }
    final main  = tensionHabitualMain  != null ? '${tensionHabitualMain}kg'  : '-';
    final cross = tensionHabitualCross != null ? '${tensionHabitualCross}kg' : '-';
    return 'M: $main  /  C: $cross';
  }

  String get nombreCompleto => '$marca $modelo';
}