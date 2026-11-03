import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_kit/media_kit.dart';
import '../services/player_service.dart';

class PlaybackControls extends StatefulWidget {
  const PlaybackControls({super.key});

  @override
  State<PlaybackControls> createState() => _PlaybackControlsState();
}

class _PlaybackControlsState extends State<PlaybackControls> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final player = context.read<PlayerService>().player;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live Progress Slider with Drag State
          StreamBuilder<Duration>(
            stream: player.stream.position,
            builder: (context, positionSnapshot) {
              return StreamBuilder<Duration>(
                stream: player.stream.duration,
                builder: (context, durationSnapshot) {
                  final position = positionSnapshot.data ?? Duration.zero;
                  final duration = durationSnapshot.data ?? Duration.zero;
                  
                  final maxDuration = duration.inSeconds.toDouble() > 0 
                      ? duration.inSeconds.toDouble() 
                      : 1.0;
                      
                  // If dragging, use the cursor's value. Otherwise, use the audio's real position.
                  final currentPosition = _isDragging 
                      ? _dragValue.clamp(0.0, maxDuration)
                      : position.inSeconds.toDouble().clamp(0.0, maxDuration);

                  return Slider(
                    value: currentPosition,
                    max: maxDuration,
                    onChangeStart: (value) {
                      setState(() {
                        _isDragging = true;
                        _dragValue = value;
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        _dragValue = value;
                      });
                    },
                    onChangeEnd: (value) {
                      player.seek(Duration(seconds: value.toInt()));
                      setState(() {
                        _isDragging = false;
                      });
                    },
                  );
                },
              );
            },
          ),
          
          // Playback Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 36),
                onPressed: () => player.previous(),
              ),
              const SizedBox(width: 24),
              StreamBuilder<bool>(
                stream: player.stream.playing,
                builder: (context, snapshot) {
                  final isPlaying = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, 
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () => player.playOrPause(),
                  );
                },
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 36),
                onPressed: () => player.next(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}