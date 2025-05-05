class AppUser {
  final String uid;
  final String email;
  final String name;
  final String role; // admin or staff
  
  AppUser({
    required this.uid,
    required this.email,
    required this.name, 
    required this.role,
  });
  
  factory AppUser.fromMap(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'staff',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
    };
  }

  @override
  String toString() {
    return 'AppUser(uid: $uid, email: $email, name: $name, role: $role)';
  }
}