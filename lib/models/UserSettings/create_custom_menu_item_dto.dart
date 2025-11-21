class CreateCustomMenuItemDto {
  // UserMenuDto özelliklerini manuel olarak ekliyoruz
  // (Inheritance yerine Composition/Direct definition Flutter'da JSON için daha güvenlidir)
  final String customMenuId; // Hangi menüye eklenecek
  final int programNo;
  final String displayName;
  final String path;
  final String icon;
  final int sortOrder;

  CreateCustomMenuItemDto({
    required this.customMenuId,
    required this.programNo,
    required this.displayName,
    required this.path,
    required this.icon,
    required this.sortOrder,
  });

  Map<String, dynamic> toJson() {
    return {
      'CustomMenuId': customMenuId,
      'ProgramNo': programNo,
      'DisplayName': displayName,
      'Path': path,
      'Icon': icon,
      'SortOrder': sortOrder,
      // ID göndermiyoruz, yeni kayıt
    };
  }
}