class UserModel {
  final String id;
  final String fname;
  final String lname;
  final String email;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.fname,
    required this.lname,
    required this.email,
    this.createdAt,
  });

  String get fullName => '$fname $lname'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fname: json['fname']?.toString() ?? '',
      lname: json['lname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
