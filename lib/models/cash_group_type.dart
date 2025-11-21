// lib/models/cash_group_type.dart
enum CashGroupType {
  Mevduat(1),
  VerilenCekler(2),
  TahsilCekler(3),
  TahsilSenetler(4),
  TeminatCekler(5),
  TeminatSenetler(6),
  MusteriKrediKarti(7),
  FirmaKrediKarti(8),
  MusteriDBS(9),
  TedarikciDbs(10),
  BankaTeminat(11);

  final int value;
  // Constructor'ı sadeleştirdik, 'text' alanını ve isteğe bağlı parametreyi kaldırdık
  const CashGroupType(this.value);

  // 'aStext' getter'ını, daha güvenli olan .name özelliğini kullanacak şekilde güncelledik
  String get aStext => name;
}