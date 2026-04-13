class ConfigModel {
  final String code;
  final String url;
  final String name;

  ConfigModel({
    required this.code,
    required this.url,
    required this.name,
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      code: json['code'] ?? '',
      url: json['url'] ?? '',
      name: json['name'] ?? '',
    );
  }

  @override
  String toString() => 'ConfigModel(code: $code, url: $url, name: $name)';
}