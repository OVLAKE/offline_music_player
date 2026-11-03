import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

// A simple model to hold track data
class LocalTrack {
  final String path;
  final String title;
  LocalTrack({required this.path, required this.title});
}

class PlayerService extends ChangeNotifier {
  late final Player _player;
  List<LocalTrack> playlist = [];
  int currentIndex = -1;

  Player get player => _player;

  PlayerService() {
    _player = Player();
    // Listen to native audio events and update the UI automatically
    _player.stream.position.listen((_) => notifyListeners());
    _player.stream.duration.listen((_) => notifyListeners());
    _player.stream.playing.listen((_) => notifyListeners());
    _player.stream.completed.listen((completed) {
      if (completed) playNext();
    });
  }

  // UI Getters
  bool get isPlaying => _player.state.playing;
  Duration get position => _player.state.position;
  Duration get duration => _player.state.duration;
  LocalTrack? get currentTrack => currentIndex >= 0 ? playlist[currentIndex] : null;

  // Load files into the queue
  void loadTracks(List<String> filePaths) {
    playlist = filePaths.map((path) {
      String filename = path.split(RegExp(r'[/\\]')).last;
      return LocalTrack(path: path, title: filename);
    }).toList();
    notifyListeners();
  }

  // Playback Controls
  void playTrack(int index) {
    if (index >= 0 && index < playlist.length) {
      currentIndex = index;
      _player.open(Media(playlist[index].path));
      notifyListeners();
    }
  }

  void togglePlayPause() => _player.playOrPause();
  void seek(Duration pos) => _player.seek(pos);
  
  void playNext() {
    if (currentIndex + 1 < playlist.length) {
      playTrack(currentIndex + 1);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}