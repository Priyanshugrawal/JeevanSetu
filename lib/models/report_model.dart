class ReportModel {
  final String id;
  final String submittedBy;    // user ka uid
  final String submitterName;
  final String problemType;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final String priority;       // HIGH, MEDIUM, LOW — Gemini decide karta hai
  final String aiReason;       // Gemini ka explanation
  final String suggestedSkills;
  final String status;         // 'pending', 'assigned', 'resolved'
  final String createdAt;

  ReportModel({
    required this.id,
    required this.submittedBy,
    required this.submitterName,
    required this.problemType,
    required this.description,
    required this.location,
    this.latitude = 0.0,
    this.longitude = 0.0,
    required this.priority,
    required this.aiReason,
    required this.suggestedSkills,
    this.status = 'pending',
    required this.createdAt,
  });
Map<String, dynamic> toMap() {
    return {
      'id': id,
      'submittedBy': submittedBy,
      'submitterName': submitterName,
      'problemType': problemType,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'priority': priority,
      'aiReason': aiReason,
      'suggestedSkills': suggestedSkills,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] ?? '',
      submittedBy: map['submittedBy'] ?? '',
      submitterName: map['submitterName'] ?? '',
      problemType: map['problemType'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      priority: map['priority'] ?? 'MEDIUM',
      aiReason: map['aiReason'] ?? '',
      suggestedSkills: map['suggestedSkills'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] ?? '',
    );
  }
}