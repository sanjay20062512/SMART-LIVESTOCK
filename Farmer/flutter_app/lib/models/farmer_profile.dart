// Farmer Profile data model
// Preserves existing structure while adding farm size, units, and preferences.

class FarmerProfile {
  final String fullName;
  final String mobileNumber;
  final String? email;
  final String preferredLanguage;
  final String state;
  final String district;
  final String block;
  final String village;
  final String? farmName;
  final String? farmSize;
  final String? farmSizeUnit; // 'Acres', 'Hectares', 'Cent'
  final String? farmLocationMode; // 'Current Location', 'Manual'
  final String livestockType;
  final String communicationPref; // 'Voice', 'Text', 'Both'

  const FarmerProfile({
    required this.fullName,
    required this.mobileNumber,
    this.email,
    this.preferredLanguage = 'English',
    required this.state,
    required this.district,
    required this.block,
    required this.village,
    this.farmName,
    this.farmSize,
    this.farmSizeUnit = 'Acres',
    this.farmLocationMode = 'Current Location',
    required this.livestockType,
    this.communicationPref = 'Both',
  });

  FarmerProfile copyWith({
    String? fullName,
    String? mobileNumber,
    String? email,
    String? preferredLanguage,
    String? state,
    String? district,
    String? block,
    String? village,
    String? farmName,
    String? farmSize,
    String? farmSizeUnit,
    String? farmLocationMode,
    String? livestockType,
    String? communicationPref,
  }) {
    return FarmerProfile(
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      state: state ?? this.state,
      district: district ?? this.district,
      block: block ?? this.block,
      village: village ?? this.village,
      farmName: farmName ?? this.farmName,
      farmSize: farmSize ?? this.farmSize,
      farmSizeUnit: farmSizeUnit ?? this.farmSizeUnit,
      farmLocationMode: farmLocationMode ?? this.farmLocationMode,
      livestockType: livestockType ?? this.livestockType,
      communicationPref: communicationPref ?? this.communicationPref,
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'mobileNumber': mobileNumber,
        'email': email,
        'preferredLanguage': preferredLanguage,
        'state': state,
        'district': district,
        'block': block,
        'village': village,
        'farmName': farmName,
        'farmSize': farmSize,
        'farmSizeUnit': farmSizeUnit,
        'farmLocationMode': farmLocationMode,
        'livestockType': livestockType,
        'communicationPref': communicationPref,
      };
}
