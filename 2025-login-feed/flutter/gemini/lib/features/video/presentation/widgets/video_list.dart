import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/features/video/domain/entities/video.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoList extends StatelessWidget {
  final List<Video> videos;

  const VideoList({super.key, required this.videos});

  Future<void> _launchUrl(String videoId) async {
    final Uri url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => _launchUrl(video.id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CachedNetworkImage(
                  imageUrl: video.thumbnailUrl,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text('Channel: ${video.channelTitle}'),
                      const SizedBox(height: 4.0),
                      Text(
                          'Published: ${DateFormat('yyyy-MM-dd').format(video.publishedAt)}'),
                      const SizedBox(height: 4.0),
                      Text('Tags: ${video.tags.join(', ')}'),
                      const SizedBox(height: 4.0),
                      if (video.locationDescription != null)
                        Text('Location: ${video.locationDescription}'),
                      if (video.recordingDate != null)
                        Text(
                            'Recorded: ${DateFormat('yyyy-MM-dd').format(video.recordingDate!)}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}