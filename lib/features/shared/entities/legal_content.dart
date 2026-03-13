class LegalContent {
  final String title;
  final String lastUpdated;
  final List<LegalSection> sections;

  LegalContent({
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  factory LegalContent.fromJson(Map<String, dynamic> json) {
    return LegalContent(
      title: json['title'] ?? '',
      lastUpdated: json['last_updated'] ?? '',
      sections: (json['sections'] as List? ?? [])
          .map((s) => LegalSection.fromJson(s))
          .toList(),
    );
  }
}

class LegalSection {
  final int? id;
  final String header;
  final String content;

  LegalSection({
    this.id,
    required this.header,
    required this.content,
  });

  factory LegalSection.fromJson(Map<String, dynamic> json) {
    return LegalSection(
      id: json['id'],
      header: json['header'] ?? '',
      content: json['content'] ?? '',
    );
  }
}
