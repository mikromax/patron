enum PriceUnitType {
  Quantity(0, 'Miktar'),
  Weight(1, 'Ağırlık'),
  Volume(2, 'Hacim');

  final int value;
  final String text;
  const PriceUnitType(this.value, this.text);

  factory PriceUnitType.fromValue(int value) {
    return values.firstWhere((e) => e.value == value, orElse: () => Quantity);
  }
}