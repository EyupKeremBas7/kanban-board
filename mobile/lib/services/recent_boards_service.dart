import 'package:shared_preferences/shared_preferences.dart';

/// Son görüntülenen pano ID'lerini kalıcı olarak saklar.
class RecentBoardsService {
  static const String _recentBoardIdsKey = 'recent_board_ids';
  static const int _maxRecentBoards = 6;

  Future<List<String>> getRecentBoardIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentBoardIdsKey) ?? <String>[];
  }

  Future<void> addRecentBoard(String boardId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_recentBoardIdsKey) ?? <String>[];

    current.remove(boardId);
    current.insert(0, boardId);

    if (current.length > _maxRecentBoards) {
      current.removeRange(_maxRecentBoards, current.length);
    }

    await prefs.setStringList(_recentBoardIdsKey, current);
  }
}
