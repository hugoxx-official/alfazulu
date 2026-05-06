class Resource {
  final String id;
  final String name;
  final String? description;
  final String category;
  final String fileType;
  final int? fileSize;
  final String? driveFileId;
  final String? thumbnailUrl;
  final String? downloadUrl;
  final int downloadCount;
  final bool isFavorite;
  final DateTime createdAt;

  Resource({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.fileType,
    this.fileSize,
    this.driveFileId,
    this.thumbnailUrl,
    this.downloadUrl,
    this.downloadCount = 0,
    this.isFavorite = false,
    required this.createdAt,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'documentacion',
      fileType: json['file_type'] ?? 'pdf',
      fileSize: json['file_size'],
      driveFileId: json['drive_file_id'],
      thumbnailUrl: json['thumbnail_url'],
      downloadUrl: json['download_url'],
      downloadCount: json['download_count'] ?? 0,
      isFavorite: json['is_favorite'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get formattedSize {
    if (fileSize == null) return 'N/A';
    final kb = fileSize! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'mapas':
        return '🗺️';
      case 'tccc':
        return '🏥';
      case 'transmisiones':
        return '📻';
      case 'manuales':
        return '📖';
      default:
        return '📄';
    }
  }

  String get fileIcon {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return '📕';
      case 'jpg':
      case 'png':
        return '🖼️';
      case 'kml':
      case 'kmz':
        return '🌍';
      case 'gpx':
        return '📍';
      default:
        return '📄';
    }
  }
}
