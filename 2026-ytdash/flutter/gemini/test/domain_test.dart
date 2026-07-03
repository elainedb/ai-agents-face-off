import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter/models/video.dart';

void main() {
  group('Video Model JSON Serialization', () {
    test('should serialize and deserialize Video correctly', () {
      final video = Video(
        id: 'vid123',
        title: 'Test Title',
        description: 'Test Description',
        publishedAt: DateTime.parse('2026-03-01T10:00:00Z'),
        category: 'tech',
        lat: 48.8566,
        lng: 2.3522,
        thumbnailUrl: 'https://test.com/thumb.jpg',
        youtubeUrl: 'https://www.youtube.com/watch?v=vid123',
      );

      final json = video.toJson();
      expect(json['id'], 'vid123');
      expect(json['title'], 'Test Title');
      expect(json['lat'], 48.8566);

      final decoded = Video.fromJson(json);
      expect(decoded.id, 'vid123');
      expect(decoded.title, 'Test Title');
      expect(decoded.lat, 48.8566);
      expect(decoded.publishedAt.isUtc, true);
    });
  });

  group('Domain Filtering and Sorting Logic', () {
    final List<Video> sampleVideos = [
      Video(
        id: '1',
        title: 'BBB Middle Clip',
        description: 'desc',
        publishedAt: DateTime.parse('2026-02-01T10:00:00Z'),
        category: 'music',
        thumbnailUrl: '',
        youtubeUrl: '',
      ),
      Video(
        id: '2',
        title: 'ZZZ Newest Clip',
        description: 'desc',
        publishedAt: DateTime.parse('2026-03-01T10:00:00Z'),
        category: 'tech',
        thumbnailUrl: '',
        youtubeUrl: '',
      ),
      Video(
        id: '3',
        title: 'AAA Oldest Clip',
        description: 'desc',
        publishedAt: DateTime.parse('2026-01-01T10:00:00Z'),
        category: 'tech',
        thumbnailUrl: '',
        youtubeUrl: '',
      ),
    ];

    test('should filter videos correctly by category', () {
      final techVideos = sampleVideos.where((v) => v.category == 'tech').toList();
      expect(techVideos.length, 2);
      expect(techVideos.any((v) => v.title == 'ZZZ Newest Clip'), true);
      expect(techVideos.any((v) => v.title == 'BBB Middle Clip'), false);
    });

    test('should sort videos descending by date', () {
      final sorted = List<Video>.from(sampleVideos);
      sorted.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      expect(sorted.first.title, 'ZZZ Newest Clip');
      expect(sorted.last.title, 'AAA Oldest Clip');
    });

    test('should sort videos ascending by date', () {
      final sorted = List<Video>.from(sampleVideos);
      sorted.sort((a, b) => a.publishedAt.compareTo(b.publishedAt));

      expect(sorted.first.title, 'AAA Oldest Clip');
      expect(sorted.last.title, 'ZZZ Newest Clip');
    });

    test('should sort videos alphabetically by title', () {
      final sorted = List<Video>.from(sampleVideos);
      sorted.sort((a, b) => a.title.compareTo(b.title));

      expect(sorted.first.title, 'AAA Oldest Clip');
      expect(sorted.last.title, 'ZZZ Newest Clip');
    });
  });

  group('Whitelist Verification Logic', () {
    final List<String> whitelist = ['user1@example.com', 'user2@example.com'];

    test('should authorize emails on the whitelist case-insensitively', () {
      const allowed1 = 'user1@example.com';
      const allowed2 = 'USER2@example.com';

      final isAllowed1 = whitelist.any((e) => e.toLowerCase().trim() == allowed1.toLowerCase().trim());
      final isAllowed2 = whitelist.any((e) => e.toLowerCase().trim() == allowed2.toLowerCase().trim());

      expect(isAllowed1, true);
      expect(isAllowed2, true);
    });

    test('should reject unauthorized emails', () {
      const unauthorized = 'unauthorized@gmail.com';
      final isAllowed = whitelist.any((e) => e.toLowerCase().trim() == unauthorized.toLowerCase().trim());
      expect(isAllowed, false);
    });
  });
}
