import 'package:flutter/material.dart';

class TokiMomentsTab extends StatefulWidget {
  final String userName;
  final String userEmoji;
  final int userBg;
  final Function(String name) onSayHi;

  const TokiMomentsTab({
    super.key,
    required this.userName,
    required this.userEmoji,
    required this.userBg,
    required this.onSayHi,
  });

  @override
  State<TokiMomentsTab> createState() => _TokiMomentsTabState();
}

class _TokiMomentsTabState extends State<TokiMomentsTab> {
  int _subTab = 0;
  String _selectedTopic = 'All';

  final List _topics = const [
    'All',
    '# Ek song chunen',
    '# Beauty',
    '# Selfie',
    '# Love',
    "# I'm New",
  ];

  final List _posts = [
    {
      'user': 'Thakurain 🐰',
      'age': '28',
      'vip': 'VIP5',
      'emoji': '👑',
      'bg': 0xFFF48FB1,
      'text': 'jisko dost banna ho msg kro',
      'cardEmoji': '🤳✨',
      'cardTitle': 'Evening Selfie Vibe',
      'c1': 0xFFFF80AB,
      'c2': 0xFF7C4DFF,
      'tag': '# Selfie',
      'meta': '2 days ago • 98.0km',
      'likes': 44,
      'comments': 13,
      'liked': false,
    },
    {
      'user': 'shivani ❤️',
      'age': '27',
      'vip': '',
      'emoji': '🌸',
      'bg': 0xFFCE93D8,
      'text': '❤️❤️❤️🙃',
      'cardEmoji': '🌹💖',
      'cardTitle': 'Long Drive & Music Mood',
      'c1': 0xFFFF7A30,
      'c2': 0xFFE91E63,
      'tag': '# Love',
      'meta': '5 hours ago • 45.2km',
      'likes': 29,
      'comments': 8,
      'liked': false,
    },
    {
      'user': 'Aarav 🎧',
      'age': '23',
      'vip': 'VIP2',
      'emoji': '🎧',
      'bg': 0xFF90CAF9,
      'text': 'Ek pyara sa gaana sunao sabko voice room mein 🎶',
      'cardEmoji': '🎤🎶',
      'cardTitle': 'Late Night Singing Party',
      'c1': 0xFF4B39EF,
      'c2': 0xFF00BCD4,
      'tag': '# Ek song chunen',
      'meta': '1 hour ago • 12.5km',
      'likes': 61,
      'comments': 19,
      'liked': false,
    },
  ];

  void _openNewPostSheet() {
    final textCtrl = TextEditingController();
    String chosenTag = '# Selfie';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('New Moment Post',
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 17,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: textCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Apne dil ki baat likhein...',
                  filled: true,
                  fillColor: const Color(0xFFF6F6F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _topics.skip(1).map((t) {
                  final tagStr = t.toString();
                  final sel = chosenTag == tagStr;
                  return ChoiceChip(
                    label: Text(tagStr, style: const TextStyle(fontSize: 12)),
                    selected: sel,
                    selectedColor: const Color(0xFFFF7A30),
                    onSelected: (_) => setModal(() => chosenTag = tagStr),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  final txt = textCtrl.text.trim();
                  if (txt.isEmpty) return;
                  setState(() {
                    _posts.insert(0, {
                      'user': widget.userName,
                      'age': '21',
                      'vip': 'VIP1',
                      'emoji': widget.userEmoji,
                      'bg': widget.userBg,
                      'text': txt,
                      'cardEmoji': '${widget.userEmoji}✨',
                      'cardTitle': chosenTag,
                      'c1': 0xFF4B39EF,
                      'c2': 0xFFFF7A30,
                      'tag': chosenTag,
                      'meta': 'Just now • 1.0km',
                      'likes': 1,
                      'comments': 0,
                      'liked': true,
                    });
                  });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A30),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Post Moment',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _posts.where((p) {
      if (_selectedTopic == 'All') return true;
      return p['tag'] == _selectedTopic;
    }).toList();
    final list = _subTab == 0 ? filtered : filtered.reversed.toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 14, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _subTab = 0),
                child: Text(
                  'Recommend',
                  style: TextStyle(
                    fontSize: _subTab == 0 ? 21 : 16,
                    fontWeight: FontWeight.bold,
                    color: _subTab == 0 ? Colors.black : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => setState(() => _subTab = 1),
                child: Text(
                  'New users',
                  style: TextStyle(
                    fontSize: _subTab == 1 ? 21 : 16,
                    fontWeight: FontWeight.bold,
                    color: _subTab == 1 ? Colors.black : Colors.grey,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _openNewPostSheet,
                icon: const Icon(Icons.camera_alt_outlined,
                    color: Colors.black87, size: 24),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              const Text('Hot Topics',
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _topics.map((topic) {
                    final topicStr = topic.toString();
                    final active = _selectedTopic == topicStr;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTopic = topicStr),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFFFF7A30)
                              : const Color(0xFFF6F6F8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          topicStr,
                          style: TextStyle(
                            color: active ? Colors.white : Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              ...list.map((p) => _buildMomentCard(p)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMomentCard(Map p) {
    final vip = p['vip'].toString();
    final isLiked = p['liked'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(p['bg'] as int),
                    child: Text(p['emoji'].toString(),
                        style: const TextStyle(fontSize: 22)),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['user'].toString(),
                        style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF80AB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('♀ ${p['age']}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                        if (vip.isNotEmpty) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('👑 $vip',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => widget.onSayHi(p['user'].toString()),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFF6D00)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text('👋 Hi',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(p['text'].toString(),
              style: const TextStyle(color: Colors.black87, fontSize: 14)),
          const SizedBox(height: 10),
          Container(
            width: 170,
            height: 150,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(p['c1'] as int),
                  Color(p['c2'] as int),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(p['cardEmoji'].toString(),
                    style: const TextStyle(fontSize: 38)),
                const SizedBox(height: 8),
                Text(
                  p['cardTitle'].toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(p['tag'].toString(),
                style: const TextStyle(color: Colors.black54, fontSize: 11)),
          ),
          const SizedBox(height: 6),
          Text(p['meta'].toString(),
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const Divider(height: 16),
          Row(
            children: [
              const Icon(Icons.more_horiz, color: Colors.grey),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    p['liked'] = !isLiked;
                    p['likes'] = (p['likes'] as int) + (isLiked ? -1 : 1);
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      size: 18,
                      color: isLiked ? const Color(0xFFFF7A30) : Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text('${p['likes']}',
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  setState(() => p['comments'] = (p['comments'] as int) + 1);
                },
                child: Row(
                  children: [
                    const Icon(Icons.edit_note,
                        size: 20, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text('${p['comments']}',
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
