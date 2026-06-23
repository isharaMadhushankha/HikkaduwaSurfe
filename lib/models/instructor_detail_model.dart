class InstructorDetailModel {
  final String id;
  final String instructorId;
  final int yearsExperience;
  final List<String> certifications;
  final List<String> surfStyles;
  final List<String> locationsServed;
  final List<String> languages;
  final double avgRating;
  final int totalReviews;

  InstructorDetailModel({
    required this.id,
    required this.instructorId,
    required this.yearsExperience,
    required this.certifications,
    required this.surfStyles,
    required this.locationsServed,
    required this.languages,
    required this.avgRating,
    required this.totalReviews,
  });

  factory InstructorDetailModel.fromMap(Map<String, dynamic> map) {
    return InstructorDetailModel(
      id: map['id'],
      instructorId: map['instructor_id'],
      yearsExperience: map['years_experience'] ?? 0,
      certifications: List<String>.from(map['certifications'] ?? []),
      surfStyles: List<String>.from(map['surf_styles'] ?? []),
      locationsServed: List<String>.from(map['locations_served'] ?? []),
      languages: List<String>.from(map['languages'] ?? []),
      avgRating: (map['avg_rating'] ?? 0).toDouble(),
      totalReviews: map['total_reviews'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'instructor_id': instructorId,
      'years_experience': yearsExperience,
      'certifications': certifications,
      'surf_styles': surfStyles,
      'locations_served': locationsServed,
      'languages': languages,
    };
  }
}
