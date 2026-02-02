class Shelter {
  final int id;
  final String name;
  final double lat;
  final double lng;

  Shelter({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
  });

  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      id: json['id'],
      name: json['name'],
      lat: json['lat'].toDouble(),
      lng: json['lng'].toDouble(),
    );
  }
}
