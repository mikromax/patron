
class ApiConfig {
  String id;
  String nickname;
  String url;

  ApiConfig({required this.id, required this.nickname, required this.url});

  // Nesneyi JSON'a çevirir (kaydetmek için)
  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'url': url,
      };

  // JSON'dan nesne oluşturur (okumak için)
  factory ApiConfig.fromJson(Map<String, dynamic> json) => ApiConfig(
        id: json['id'],
        nickname: json['nickname'],
        url: json['url'],
      );
}