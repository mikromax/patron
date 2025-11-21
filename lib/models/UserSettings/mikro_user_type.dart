// lib/models/UserSettings/mikro_user_type.dart
enum MikroUserType {
  Plasiyer(0),
  Standart(1),
  Cari(2);

  final int value;
  const MikroUserType(this.value);

  // int'ten enum'a çevirmek için
  factory MikroUserType.fromValue(int value) {
    return values.firstWhere((e) => e.value == value, orElse: () => Standart);
  }

  // Enum'ı metne çevirmek için
  String get aStext {
    switch (this) {
      case MikroUserType.Plasiyer: return 'Plasiyer (Temsilci)';
      case MikroUserType.Standart: return 'Standart (İç Kullanıcı)';
      case MikroUserType.Cari: return 'Cari (Müşteri/Satıcı)';
    }
  }
}