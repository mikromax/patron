// lib/models/account_types.dart
enum AccountTypes {
  Carimiz(0),
  CariPersonelimiz(1),
  Bankamiz(2),
  Hizmetimiz(3),
  Kasamiz(4),
  Giderimiz(5),
  MuhasebeHesabimiz(6),
  Personelimiz(7),
  Demirbasimiz(8),
  IthalatDosyamiz(9),
  FinansalSozzlesmemiz(10),
  KrediSozlesmemiz(11),
  Stok(101);

  final int value;
  const AccountTypes(this.value);
}