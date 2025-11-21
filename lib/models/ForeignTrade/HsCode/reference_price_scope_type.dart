enum ReferencePriceScopeType {
  AllCountries(0, 'Tüm Ülkeler'),
  IncludeList(1, 'Sadece Listedekiler (Beyaz Liste)'),
  ExcludeList(2, 'Listedekiler Hariç (Kara Liste)');

  final int value;
  final String text;
  const ReferencePriceScopeType(this.value, this.text);

  factory ReferencePriceScopeType.fromValue(int value) {
    return values.firstWhere((e) => e.value == value, orElse: () => AllCountries);
  }
}