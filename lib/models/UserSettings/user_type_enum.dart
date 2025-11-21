// lib/models/UserSettings/user_type_enum.dart
enum UserType {
  Employee(0, 'Employee'),
  Other(1, 'Diğer');

  final int value;
  final String text;
  const UserType(this.value, this.text);
}