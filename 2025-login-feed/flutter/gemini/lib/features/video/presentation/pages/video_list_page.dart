import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/features/video/presentation/bloc/video_bloc.dart';
import 'package:flutter_gemini/features/video/presentation/bloc/video_event.dart';
import 'package:flutter_gemini/features/video/presentation/bloc/video_state.dart';
import 'package:flutter_gemini/features/video/presentation/widgets/video_list_item.dart';

class VideoListPage extends StatefulWidget {
  const VideoListPage({super.key});

  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  @override
  void initState() {
    super.initState();
    context.read<VideoBloc>().add(const VideoEvent.getVideos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos'),
      ),
      body: BlocBuilder<VideoBloc, VideoState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (videos) {
              return ListView.builder(
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return VideoListItem(video: video);
                },
              );
            },
            error: (message) => Center(child: Text(message)),
          );
        },
      ),
    );
  }
}
