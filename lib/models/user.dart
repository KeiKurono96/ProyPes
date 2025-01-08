class UserProfile {
  final String uid;
  final String email;
  final String tipo;
  final String? nombres;
  final String? apellidos;
  final String? sexo;
  final String? direccion;
  final String? telefono;

  UserProfile({
    required this.uid, 
    required this.email,
    required this.tipo,
    this.nombres,
    this.apellidos,
    this.sexo,
    this.direccion,
    this.telefono,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'tipo': tipo,
      'nombres': nombres,
      'apellidos': apellidos,
      'sexo': sexo,
      'direccion': direccion,
      'telefono': telefono,
    };
  }
}