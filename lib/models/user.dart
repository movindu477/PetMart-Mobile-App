class User {
  final int id;
  final String name;
  final String email;
  final String? profilePhotoUrl;
  final String? phone;
  final String? address;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhotoUrl,
    this.phone,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: (json['name'] ?? json['full_name'] ?? json['username'] ?? '')
          .toString(),
      email: (json['email'] ?? '').toString(),
      profilePhotoUrl:
          (json['profile_photo_url'] ?? json['avatar'] ?? json['image'])
              ?.toString(),
      phone: (json['phone'] ?? json['phone_number'] ?? json['mobile'] ?? '')
          .toString(),
      address:
          (json['address'] ??
                  json['location'] ??
                  json['shipping_address'] ??
                  '')
              .toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_photo_url': profilePhotoUrl,
      'phone': phone,
      'address': address,
    };
  }
}
