import 'package:cloud_firestore/cloud_firestore.dart';

enum ContentType { radio, podcast, stream }

class Station {
  final String id;
  final String name;
  final String streamUrl;
  final String? logoUrl;
  final String? genre;
  final String? frequency;
  final String? callSign;
  final String? country;
  final String? language;
  final List<String> tags;
  final bool isCustom;
  final ContentType contentType;
  final String? description;
  final String? host;
  final DateTime? createdAt;

  Station({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.logoUrl,
    this.genre,
    this.frequency,
    this.callSign,
    this.country,
    this.language,
    this.tags = const [],
    this.isCustom = false,
    this.contentType = ContentType.radio,
    this.description,
    this.host,
    this.createdAt,
  });

  factory Station.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Station(
      id: doc.id,
      name: data['name'] ?? '',
      streamUrl: data['streamUrl'] ?? '',
      logoUrl: data['logoUrl'],
      genre: data['genre'],
      frequency: data['frequency'],
      callSign: data['callSign'],
      country: data['country'],
      language: data['language'],
      tags: List<String>.from(data['tags'] ?? []),
      isCustom: data['isCustom'] ?? false,
      contentType: ContentType.values.firstWhere(
        (e) => e.name == data['contentType'],
        orElse: () => ContentType.radio,
      ),
      description: data['description'],
      host: data['host'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'streamUrl': streamUrl,
      'logoUrl': logoUrl,
      'genre': genre,
      'frequency': frequency,
      'callSign': callSign,
      'country': country,
      'language': language,
      'tags': tags,
      'isCustom': isCustom,
      'contentType': contentType.name,
      'description': description,
      'host': host,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  // JSON serialization for favorites storage
  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      streamUrl: json['streamUrl'] ?? '',
      logoUrl: json['logoUrl'],
      genre: json['genre'],
      frequency: json['frequency'],
      callSign: json['callSign'],
      country: json['country'],
      language: json['language'],
      tags: List<String>.from(json['tags'] ?? []),
      isCustom: json['isCustom'] ?? false,
      contentType: ContentType.values.firstWhere(
        (e) => e.name == json['contentType'],
        orElse: () => ContentType.radio,
      ),
      description: json['description'],
      host: json['host'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'streamUrl': streamUrl,
      'logoUrl': logoUrl,
      'genre': genre,
      'frequency': frequency,
      'callSign': callSign,
      'country': country,
      'language': language,
      'tags': tags,
      'isCustom': isCustom,
      'contentType': contentType.name,
      'description': description,
      'host': host,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Station copyWith({
    String? id,
    String? name,
    String? streamUrl,
    String? logoUrl,
    String? genre,
    String? frequency,
    String? callSign,
    String? country,
    String? language,
    List<String>? tags,
    bool? isCustom,
    ContentType? contentType,
    String? description,
    String? host,
    DateTime? createdAt,
  }) {
    return Station(
      id: id ?? this.id,
      name: name ?? this.name,
      streamUrl: streamUrl ?? this.streamUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      genre: genre ?? this.genre,
      frequency: frequency ?? this.frequency,
      callSign: callSign ?? this.callSign,
      country: country ?? this.country,
      language: language ?? this.language,
      tags: tags ?? this.tags,
      isCustom: isCustom ?? this.isCustom,
      contentType: contentType ?? this.contentType,
      description: description ?? this.description,
      host: host ?? this.host,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}