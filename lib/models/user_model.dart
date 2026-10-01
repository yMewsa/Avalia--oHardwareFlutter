class UserModel {
  final String uid;
  final String email;
  final String nif;
  final String? name;

  UserModel({
    required this.uid,
    required this.email,
    required this.nif,
    this.name,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      nif: map['nif'] ?? '',
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nif': nif,
      'name': name,
    };
  }
}
