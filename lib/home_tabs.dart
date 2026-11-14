import 'package:flutter/material.dart';

class TokiHomeTabs {
  static Widget fBtn(String label, int idx, int cur, ValueChanged<int> onTap) {
    final act = cur == idx;
    return GestureDetector(
      onTap: () => onTap(idx),
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Text(
          label,
          style: TextStyle(
            fontSize: act ? 19 : 15,
            fontWeight: FontWeight.bold,
            color: act ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  static Widget homeTab({
    required List users,
    required int homeFilter,
    required ValueChanged<int> onFilter,
    required Function(String name, String emoji, String room) onSayHi,
    required Function(String title) onEnterRoom,
  }) {
    final list = users
        .where((u) => homeFilter == 1
            ? u['new'] == true
            : (homeFilter == 2 ? u['feat'] == true : true))
        .toList();
    return ListView(padding: const EdgeInsets.all(14), children: [
      Row(children: [
        fBtn('Recommend', 0, homeFilter, onFilter),
        fBtn('New users', 1, homeFilter, onFilter),
        fBtn('Featured', 2, homeFilter, onFilter),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onSayHi('Riya Sharma', '🌸', 'welcome everyone 🎶'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFF8A65), Color(0xFFFF7043)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💖 SoulLink',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text('Instant dost match',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => onEnterRoom('welcome everyone 🎶'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF4B39EF), Color(0xFF7C4DFF)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🎙️ Party Room',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text('9-Seat Live Voice',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 12),
      ...list.map((u) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(u['bg'] as int),
                  child: Text(u['e'].toString(),
                      style: const TextStyle(fontSize: 24))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('${u['name']}  •  👑 ${u['vip']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(u['bio'].toString(),
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12)),
                  ])),
              ElevatedButton(
                onPressed: () => onSayHi(u['name'].toString(),
                    u['e'].toString(), u['room'].toString()),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A30),
                    foregroundColor: Colors.white),
                child: const Text('👋 Hi'),
              ),
            ]),
          )),
    ]);
  }

  static Widget momentsTab({
    required List moments,
    required VoidCallback onPostMoment,
    required Function(int i, bool liked) onToggleLike,
    required Function(String name, String emoji, String room) onSayHi,
  }) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        child: Row(children: [
          const Text('🪐 Moments',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const Spacer(),
          ElevatedButton(
            onPressed: onPostMoment,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A30),
                foregroundColor: Colors.white),
            child: const Text('+ Post'),
          ),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: moments.length,
          itemBuilder: (_, i) {
            final m = moments[i];
            final liked = m['liked'] == true;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      CircleAvatar(
                          backgroundColor: Color(m['bg'] as int),
                          child: Text(m['e'].toString())),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text('${m['name']}\n${m['time']}',
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 13))),
                      TextButton(
                          onPressed: () => onSayHi(m['name'].toString(),
                              m['e'].toString(), 'welcome everyone 🎶'),
                          child: const Text('👋 Hi',
                              style: TextStyle(color: Color(0xFFFF7A30)))),
                    ]),
                    const SizedBox(height: 8),
                    Text(m['text'].toString(),
                        style: const TextStyle(color: Colors.black87)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Text(m['tag'].toString(),
                          style: const TextStyle(
                              color: Color(0xFFFF7A30), fontSize: 12)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => onToggleLike(i, liked),
                        child: Row(children: [
                          Icon(liked ? Icons.favorite : Icons.favorite_border,
                              color: liked ? Colors.red : Colors.grey,
                              size: 20),
                          Text(' ${m['likes']}'),
                        ]),
                      ),
                    ]),
                  ]),
            );
          },
        ),
      ),
    ]);
  }

  static Widget roomsTab({
    required List rooms,
    required int roomFilter,
    required bool searching,
    required String query,
    required TextEditingController searchCtrl,
    required bool bonusClaimed,
    required int coins,
    required ValueChanged<int> onFilter,
    required VoidCallback onToggleSearch,
    required ValueChanged<String> onQueryChanged,
    required VoidCallback onCreateRoom,
    required VoidCallback onClaimBonus,
    required Function(String title) onEnterRoom,
  }) {
    final list = rooms.where((r) {
      if (query.isNotEmpty &&
          !r['title'].toString().toLowerCase().contains(query.toLowerCase())) {
        return false;
      }
      if (roomFilter == 1) return r['cat'] == 'Video';
      if (roomFilter == 2) return r['cat'] == 'New';
      if (roomFilter == 3) return r['mine'] == true;
      return true;
    }).toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
        child: Row(children: [
          fBtn('Recommend', 0, roomFilter, onFilter),
          fBtn('Video', 1, roomFilter, onFilter),
          fBtn('New', 2, roomFilter, onFilter),
          fBtn('Me', 3, roomFilter, onFilter),
          const Spacer(),
          GestureDetector(
              onTap: onToggleSearch, child: const Icon(Icons.search)),
          const SizedBox(width: 10),
          GestureDetector(
              onTap: onCreateRoom, child: const Icon(Icons.add_box_outlined)),
        ]),
      ),
      if (searching)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: TextField(
            controller: searchCtrl,
            onChanged: onQueryChanged,
            decoration: const InputDecoration(
                hintText: 'Room khojein...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder()),
          ),
        ),
      GestureDetector(
        onTap: onClaimBonus,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFFF9E67), Color(0xFFFF7A30)]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            Expanded(
                child: Text(
                    bonusClaimed
                        ? 'Event Center • Bonus Claimed (🪙 $coins)'
                        : 'Event Center • Tap for +300 Free Coins ➔',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            const Icon(Icons.event_note, color: Colors.white, size: 30),
          ]),
        ),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final r = list[i];
            return GestureDetector(
              onTap: () => onEnterRoom(r['title'].toString()),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Color(r['c1'] as int),
                        Color(r['c2'] as int)
                      ]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(r['e'].toString(),
                        style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(r['title'].toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87)),
                        Text(r['sub'].toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(r['tag'].toString(),
                            style: TextStyle(
                                color: Color(r['tc'] as int),
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ])),
                  Text('📶 ${r['views']}',
                      style: const TextStyle(
                          color: Color(0xFFFF7A30),
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }
}
