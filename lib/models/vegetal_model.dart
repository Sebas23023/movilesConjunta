class Vegetal {
  final int codigo;
  final String descripcion;
  final double precio;

  Vegetal({
    required this.codigo,
    required this.descripcion,
    required this.precio,
  });

  factory Vegetal.fromJson(Map<String, dynamic> json) {
    return Vegetal(
      codigo: json['codigo'],
      descripcion: json['descripcion'],
      precio: json['precio'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'descripcion': descripcion,
      'precio': precio,
    };
  }
}
