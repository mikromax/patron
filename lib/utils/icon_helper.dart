import 'package:flutter/material.dart';

class IconHelper {
  // Tüm ikon anahtarlarımızı ve karşılıklarını tanımladığımız yer
  static final Map<String, IconData> iconMap = {
    // Menü İkonları
    'settings': Icons.settings,
    'widget_settings': Icons.dashboard_customize,
    'folder': Icons.folder,
    'apps': Icons.apps,

    // Scorecard İkonları (ve diğerleri)
    'account_balance': Icons.account_balance,
    'money_off': Icons.money_off,
    'trending_up': Icons.trending_up,
    'credit_card': Icons.credit_card,
    'inventory': Icons.inventory,
    'assessment': Icons.assessment,
    'shopping_cart': Icons.shopping_cart,
    'people': Icons.people,
    'business': Icons.business,
    'list_alt': Icons.list_alt,
    'pie_chart': Icons.pie_chart,
    'bar_chart': Icons.bar_chart,

    // Varsayılan ikon
    'default': Icons.apps,
  };

  // String isme göre IconData döndürür
  static IconData getIconFromString(String? iconName) {
    if (iconName == null || !iconMap.containsKey(iconName)) {
      return iconMap['default']!; // Anahtar bulunamazsa 'default' ikonunu döndür
    }
    return iconMap[iconName]!;
  }

  // Dropdown için menü öğeleri listesi oluşturur
  static List<DropdownMenuItem<String>> getIconDropdownItems() {
    return iconMap.entries.map((entry) {
      // 'folder' veya 'apps' gibi sistem ikonlarını seçtirmeyelim
      if (entry.key == 'folder' || entry.key == 'apps' || entry.key == 'default') {
        return null;
      }
      return DropdownMenuItem<String>(
        value: entry.key,
        child: Row(
          children: [
            Icon(entry.value, color: Colors.indigo),
            const SizedBox(width: 8),
            Text(entry.key),
          ],
        ),
      );
    }).where((item) => item != null).toList().cast<DropdownMenuItem<String>>(); // null olanları filtrele
  }
}