import 'resource.dart';

class MapResource extends Resource {
  final String? scale;
  final String? region;
  final Map<String, dynamic>? coordinates;

  MapResource({
    required super.id,
    required super.name,
    super.description,
    required super.category,
    required super.fileType,
    super.fileSize,
    super.driveFileId,
    super.thumbnailUrl,
    super.downloadUrl,
    super.downloadCount,
    super.isFavorite,
    required super.createdAt,
    this.scale,
    this.region,
    this.coordinates,
  });

  factory MapResource.fromJson(Map<String, dynamic> json) {
    return MapResource(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'mapas',
      fileType: json['file_type'] ?? 'pdf',
      fileSize: json['file_size'],
      driveFileId: json['drive_file_id'],
      thumbnailUrl: json['thumbnail_url'],
      downloadUrl: json['download_url'],
      downloadCount: json['download_count'] ?? 0,
      isFavorite: json['is_favorite'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      scale: json['scale'],
      region: json['region'],
      coordinates: json['coordinates'],
    );
  }
}
