class User{
  final int userId;
  final String email;
  final String password;
  final String nombres;
  final String apellidos;
  final String sexo;
  final String? direccion;
  final String? telefono;
  final String tipo;
  final DateTime? fechaCreacion;
  final DateTime? fechaModificacion;

  const User ({
    required this.userId,
    required this.email,
    required this.password,
    required this.nombres,
    required this.apellidos,
    required this.sexo,
    this.direccion,
    this.telefono,
    required this.tipo,
    this.fechaCreacion,
    this.fechaModificacion,
  });

  const User.empty({
    this.userId = 0,
    this.email = '',
    this.password = '',
    this.nombres = '',
    this.apellidos = '',
    this.sexo = 'm',
    this.direccion,
    this.telefono,
    this.tipo = 'doc',
    this.fechaCreacion,
    this.fechaModificacion
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json['userId'],
    email: json['email'],
    password: json['password'],
    nombres: json['nombres'],
    apellidos: json['apellidos'],
    sexo: json['sexo'],
    direccion: json['direccion'],
    telefono: json['telefono'],
    tipo: json['tipo'],
  );

  Map<String, dynamic> toJson()=>{
    "userId":userId,
    "email":email,
    "password":password,
    "nombres":nombres,
    "apellidos":apellidos,
    "sexo":sexo,
    "direccion":direccion,
    "telefono":telefono,
    "tipo":tipo
  };
}