
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/features/map/domain/entities/video_location.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoBottomSheet extends StatelessWidget {
  final VideoLocation location;
  const VideoBottomSheet({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final Uri url = Uri.parse(location.videoUrl);
        if (!await launchUrl(url)) {
          throw Exception('Could not launch $url');
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.25,
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: location.thumbnailUrl,
              width: 120,
              height: 90,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    location.channelTitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Published: ${DateFormat.yMMMd().format(location.publicationDate)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (location.recordingDate != null)
                    Text(
                      'Recorded: ${DateFormat.yMMMd().format(location.recordingDate!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  Text(
                    'Location: ${location.city}, ${location.country}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Tags: ${location.tags.join(', ')}',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
