class UserData {
  final String mobile;
  final String name;
  final String userProfile;
  final String mailid;

  UserData({
    required this.mobile,
    required this.name,
    required this.userProfile,
    required this.mailid,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      mobile: json['mobile'] ?? '',
      name: json['name'] ?? 'Unknown',
      userProfile: json['userProfile'] ?? '',
      mailid: json['mailid'] ?? 'Not Provided',
    );
  }
}
