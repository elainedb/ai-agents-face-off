import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/features/video/presentation/bloc/video_bloc.dart';
import 'package:flutter_gemini/features/video/presentation/bloc/video_event.dart';
import 'package:flutter_gemini/features/video/presentation/bloc/video_state.dart';
import 'package:flutter_gemini/features/video/presentation/widgets/video_list.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  @override
  void initState() {
    super.initState();
    // Dispatch the initial fetch event when the page is first created.
    context.read<VideoBloc>().add(const FetchVideos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<VideoBloc>().add(const FetchVideos(forceRefresh: true));
            },
          ),
          BlocBuilder<VideoBloc, VideoState>(
            builder: (context, state) {
              if (state is VideoLoaded) {
                return IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterDialog(context, state),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          BlocBuilder<VideoBloc, VideoState>(
            builder: (context, state) {
              if (state is VideoLoaded) {
                return IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: () => _showSortDialog(context, state),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<VideoBloc, VideoState>(
        builder: (context, state) {
          if (state is VideoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VideoLoaded) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Total Videos: ${state.filteredVideos.length}'),
                ),
                Expanded(
                  child: VideoList(videos: state.filteredVideos),
                ),
              ],
            );
          } else if (state is VideoError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context, VideoLoaded state) {
    final channels =
        state.originalVideos.map((v) => v.channelTitle).toSet().toList();
    final countries = state.originalVideos
        .where((v) => v.country != null)
        .map((v) => v.country!)
        .toSet()
        .toList();

    String? selectedChannel = state.filter.channel;
    String? selectedCountry = state.filter.country;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Filter Videos'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedChannel,
                    hint: const Text('Select Channel'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Channels'),
                      ),
                      ...channels.map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          )),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedChannel = value;
                      });
                    },
                  ),
                  DropdownButton<String>(
                    value: selectedCountry,
                    hint: const Text('Select Country'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Countries'),
                      ),
                      ...countries.map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          )),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCountry = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<VideoBloc>().add(FilterVideos(VideoFilter()));
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                context.read<VideoBloc>().add(FilterVideos(VideoFilter(
                      channel: selectedChannel,
                      country: selectedCountry,
                    )));
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showSortDialog(BuildContext context, VideoLoaded state) {
    showModalBottomSheet(
      context: context,
      builder: (dialogContext) {
        return Wrap(
          children: [
            ListTile(
              title: const Text('Publication Date (Newest First)'),
              onTap: () {
                context.read<VideoBloc>().add(SortVideos(VideoSort(
                    key: SortKey.publicationDate,
                    direction: SortDirection.desc)));
                Navigator.of(dialogContext).pop();
              },
            ),
            ListTile(
              title: const Text('Publication Date (Oldest First)'),
              onTap: () {
                context.read<VideoBloc>().add(SortVideos(VideoSort(
                    key: SortKey.publicationDate,
                    direction: SortDirection.asc)));
                Navigator.of(dialogContext).pop();
              },
            ),
            ListTile(
              title: const Text('Recording Date (Newest First)'),
              onTap: () {
                context.read<VideoBloc>().add(SortVideos(VideoSort(
                    key: SortKey.recordingDate,
                    direction: SortDirection.desc)));
                Navigator.of(dialogContext).pop();
              },
            ),
            ListTile(
              title: const Text('Recording Date (Oldest First)'),
              onTap: () {
                context.read<VideoBloc>().add(SortVideos(VideoSort(
                    key: SortKey.recordingDate,
                    direction: SortDirection.asc)));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
