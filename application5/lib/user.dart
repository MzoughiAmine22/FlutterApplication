class User {
  int id;
  String email;
  String role;

  User(this.id, this.email, this.role);

  factory User.fromMap(Map<String, dynamic> map) => User(
    map["id"],
    map["email"],
    map["role"] ?? "user",
  );
}