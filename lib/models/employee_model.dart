import 'package:equatable/equatable.dart';

enum UserRole {
  admin("Quản trị viên"),
  employee("Nhân viên");

  final String label;

  const UserRole(this.label);

  bool get isAdmin => this == UserRole.admin;
}

class EmployeeModel extends Equatable {
  final String id;
  final String empCode;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final UserRole userRole;
  final String avatarUrl;
  final String department;
  // Antigravity: Đổi từ createAt sang createdAt để chuẩn hóa và khớp với cột 'created_at' trong Supabase
  final DateTime createdAt;

  const EmployeeModel({
    required this.id,
    required this.empCode,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.userRole,
    required this.avatarUrl,
    required this.department,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'emp_code': empCode,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'user_role': userRole.name,
      'avatar_url': avatarUrl,
      'department': department,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      id: map['id'] as String? ?? '',
      empCode: map['emp_code'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phoneNumber: map['phone_number'] as String?,
      userRole: UserRole.values.firstWhere(
        (e) => e.name == map['user_role'],
        orElse: () => UserRole.employee,
      ),
      avatarUrl: map['avatar_url'] as String? ?? '',
      department: map['department'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  EmployeeModel copyWith({
    String? id,
    String? empCode,
    String? fullName,
    String? email,
    String? phoneNumber,
    UserRole? userRole,
    String? avatarUrl,
    String? department,
    DateTime? createdAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      empCode: empCode ?? this.empCode,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userRole: userRole ?? this.userRole,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      department: department ?? this.department,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  @override
  List<Object?> get props=>[
    id,
    empCode,
    fullName,
    email,
    phoneNumber,
    userRole,
    avatarUrl,
    department,
    createdAt
  ];
}
