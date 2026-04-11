class OrdenServicio {
  final String  id;
  final String  clienteId;
  final String? clienteNombre;
  final String  raquetaId;
  final String  cuerdaMainId;
  final String  cuerdaCrossId;
  final bool    srvEncordado;
  final bool    srvGrip;
  final bool    srvLimpieza;
  final bool    srvLogo;
  final double? tensionMain;
  final double? tensionCross;
  final double  precioTotal;
  final bool    pagado;
  final String  estado;
  final DateTime fechaEntrada;
  final DateTime? fechaPrevista;
  final DateTime? fechaEntregaReal;
  final String? notas;

  OrdenServicio({
    required this.id,
    required this.clienteId,
    this.clienteNombre,
    required this.raquetaId,
    required this.cuerdaMainId,
    required this.cuerdaCrossId,
    required this.srvEncordado,
    required this.srvGrip,
    required this.srvLimpieza,
    required this.srvLogo,
    this.tensionMain,
    this.tensionCross,
    required this.precioTotal,
    required this.pagado,
    required this.estado,
    required this.fechaEntrada,
    this.fechaPrevista,
    this.fechaEntregaReal,
    this.notas,
  });

  factory OrdenServicio.fromJson(Map<String, dynamic> json) {
    return OrdenServicio(
      id:             json['id']              as String,
      clienteId:      json['cliente_id']      as String,
      clienteNombre: json['clientes'] != null
          ? '${json['clientes']['nombre']} ${json['clientes']['apellidos']}'
          : null,
      raquetaId:      json['raqueta_id']      as String,
      cuerdaMainId:   json['cuerda_main_id']  as String,
      cuerdaCrossId:  json['cuerda_cross_id'] as String,
      srvEncordado:   json['srv_encordado']   as bool,
      srvGrip:        json['srv_grip']        as bool,
      srvLimpieza:    json['srv_limpieza']    as bool,
      srvLogo:        json['srv_logo']        as bool,
      tensionMain:    (json['tension_main']   as num?)?.toDouble(),
      tensionCross:   (json['tension_cross']  as num?)?.toDouble(),
      precioTotal:    (json['precio_total']   as num).toDouble(),
      pagado:         json['pagado']          as bool,
      estado:         json['estado']          as String,
      fechaEntrada:   DateTime.parse(json['fecha_entrada'] as String),
      fechaPrevista:  json['fecha_prevista'] != null
                        ? DateTime.parse(json['fecha_prevista'] as String)
                        : null,
      fechaEntregaReal: json['fecha_entrega_real'] != null
                        ? DateTime.parse(json['fecha_entrega_real'] as String)
                        : null,
      notas:          json['notas'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cliente_id':       clienteId,
      'raqueta_id':       raquetaId,
      'cuerda_main_id':   cuerdaMainId,
      'cuerda_cross_id':  cuerdaCrossId,
      'srv_encordado':    srvEncordado,
      'srv_grip':         srvGrip,
      'srv_limpieza':     srvLimpieza,
      'srv_logo':         srvLogo,
      'tension_main':     tensionMain,
      'tension_cross':    tensionCross,
      'precio_total':     precioTotal,
      'pagado':           pagado,
      'estado':           estado,
      'fecha_entrada':    fechaEntrada.toIso8601String(),
      'fecha_prevista':   fechaPrevista?.toIso8601String(),
      'fecha_entrega_real': fechaEntregaReal?.toIso8601String(),
      'notas':            notas,
    };
  }

  OrdenServicio copyWith({
    String?   cuerdaMainId,
    String?   cuerdaCrossId,
    bool?     srvGrip,
    bool?     srvLimpieza,
    bool?     srvLogo,
    double?   tensionMain,
    double?   tensionCross,
    double?   precioTotal,
    bool?     pagado,
    String?   estado,
    DateTime? fechaPrevista,
    DateTime? fechaEntregaReal,
    String?   notas,
  }) {
    return OrdenServicio(
      id:               id,
      clienteId:        clienteId,
      raquetaId:        raquetaId,
      cuerdaMainId:     cuerdaMainId    ?? this.cuerdaMainId,
      cuerdaCrossId:    cuerdaCrossId   ?? this.cuerdaCrossId,
      srvEncordado:     srvEncordado,
      srvGrip:          srvGrip         ?? this.srvGrip,
      srvLimpieza:      srvLimpieza     ?? this.srvLimpieza,
      srvLogo:          srvLogo         ?? this.srvLogo,
      tensionMain:      tensionMain     ?? this.tensionMain,
      tensionCross:     tensionCross    ?? this.tensionCross,
      precioTotal:      precioTotal     ?? this.precioTotal,
      pagado:           pagado          ?? this.pagado,
      estado:           estado          ?? this.estado,
      fechaEntrada:     fechaEntrada,
      fechaPrevista:    fechaPrevista   ?? this.fechaPrevista,
      fechaEntregaReal: fechaEntregaReal ?? this.fechaEntregaReal,
      notas:            notas           ?? this.notas,
    );
  }

  // Helpers para UI
  String get precioDisplay => '${precioTotal.toStringAsFixed(2)} €';

  String get estadoDisplay {
    switch (estado) {
      case 'pendiente':   return 'Pendiente';
      case 'en_proceso':  return 'En proceso';
      case 'listo':       return 'Listo';
      case 'entregado':   return 'Entregado';
      default:            return estado;
    }
  }

  List<String> get serviciosActivos {
    final lista = <String>[];
    if (srvEncordado) lista.add('Encordado');
    if (srvGrip)      lista.add('Grip');
    if (srvLimpieza)  lista.add('Limpieza');
    if (srvLogo)      lista.add('Logo');
    return lista;
  }
}