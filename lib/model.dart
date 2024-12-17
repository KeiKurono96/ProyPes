class User{
  final int id;
  final String email;
  final String password;

  const User ({
    required this.id,
    required this.email,
    required this.password
  });

  const User.empty({
    this.id = 0,
    this.email = '',
    this.password = '',
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    password: json['password'],
  );

  Map<String, dynamic> toJson()=>{
    "id":id,
    "email":email,
    "password":password
  };
}