              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 9,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.05,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final occupant = _seats[index];
                final isOccupied = occupant != null;
                final uid = isOccupied ? occupant['uid'] : null;
                final isSpeaking = uid != null && _speakingUids.contains(uid);
                final isMe = uid == _localUid;
                final isHostSeat = index == 0;

                return GestureDetector(
                  onTap: () {
                    if (!isOccupied) {
                      _takeSeat(index);
                    } else if (isMe) {
                      _leaveSeat(index);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1533),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSpeaking
                            ? Colors.greenAccent
                            : (isHostSeat
                                ? Colors.amber
                                : (isOccupied
                                    ? const Color(0xFF4B39EF)
                                    : Colors.white12)),
                        width: isSpeaking ? 2.5 : 1.3,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: isHostSeat
                              ? Colors.amber.shade700
                              : (isOccupied
                                  ? const Color(0xFF4B39EF)
                                  : Colors.white10),
                          child: Icon(
                            isHostSeat
                                ? Icons.star
                                : (isOccupied ? Icons.person : Icons.mic_none),
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isOccupied
                              ? occupant['name'].toString()
                              : (isHostSeat ? 'Host Seat' : 'Seat ${index + 1}'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isOccupied
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isOccupied ? Colors.white : Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1533),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${msg['sender']}: ',
                            style: const TextStyle(
                              color: Color(0xFF9D8DF1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: msg['text'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: const Color(0xFF15112B),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Say something in party...',
                      filled: true,
                      fillColor: const Color(0xFF231D42),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendChat(),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: _sendChat,
                  icon: const Icon(Icons.send, color: Color(0xFF4B39EF)),
                ),
                IconButton(
                  onPressed: _toggleMute,
                  icon: Icon(
                    _isMuted ? Icons.mic_off : Icons.mic,
                    color: _isMuted ? Colors.redAccent : Colors.greenAccent,
                  ),
                ),
                IconButton(
                  onPressed: _openGifts,
                  icon: const Icon(Icons.card_giftcard,
                      color: Colors.pinkAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
