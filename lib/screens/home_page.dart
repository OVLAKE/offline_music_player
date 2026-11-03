import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../services/player_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _pickAudioFiles(BuildContext context) async {
  // Bypassing .platform completely since your compiler rejects it
  dynamic result = await FilePicker.pickFiles(
    type: FileType.audio,
  );

  if (result != null) {
    // Safely extract paths regardless of how your specific package version formats the result
    List<String> paths = result is List 
        ? result.map((f) => f.path.toString()).toList()
        : result.paths.whereType<String>().toList();

    if (context.mounted && paths.isNotEmpty) {
      context.read<PlayerService>().loadTracks(paths);
      context.read<PlayerService>().playTrack(0);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final service = context.watch<PlayerService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Music'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_to_photos),
            tooltip: 'Add Music Files',
            onPressed: () => _pickAudioFiles(context),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: service.playlist.isEmpty
                ? const Center(child: Text('Tap the + icon to add music.'))
                : ListView.builder(
                    itemCount: service.playlist.length,
                    itemBuilder: (context, index) {
                      final track = service.playlist[index];
                      final isSelected = service.currentIndex == index;

                      return ListTile(
                        leading: Icon(
                          isSelected && service.isPlaying 
                              ? Icons.graphic_eq 
                              : Icons.music_note,
                          color: isSelected ? Colors.tealAccent : null,
                        ),
                        title: Text(
                          track.title, 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => service.playTrack(index),
                      );
                    },
                  ),
          ),
          if (service.currentTrack != null) _buildPlayerControls(context, service),
        ],
      ),
    );
  }

  Widget _buildPlayerControls(BuildContext context, PlayerService service) {
    final current = service.currentTrack!;
    final maxSeconds = service.duration.inSeconds.toDouble();
    final currentSeconds = service.position.inSeconds.toDouble().clamp(0.0, maxSeconds > 0 ? maxSeconds : 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            current.title, 
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Slider(
            value: currentSeconds,
            max: maxSeconds > 0 ? maxSeconds : 1.0,
            onChanged: (val) => service.seek(Duration(seconds: val.toInt())),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(service.isPlaying ? Icons.pause_circle : Icons.play_circle),
                iconSize: 48,
                onPressed: service.togglePlayPause,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                iconSize: 36,
                onPressed: service.playNext,
              ),
            ],
          )
        ],
      ),
    );
  }
}