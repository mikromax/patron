class NewSessionDto {
  final String newSessionId;

  NewSessionDto({required this.newSessionId});

  factory NewSessionDto.fromJson(Map<String, dynamic> json) {
    return NewSessionDto(
      newSessionId: json['newSessionId'] as String,
    );
  }
}