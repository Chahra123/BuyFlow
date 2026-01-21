import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/complaint_models.dart';
import '../../data/services/complaints_service.dart';

final _complaintsServiceProvider = Provider((ref) => ComplaintsService());

class ComplaintChatScreen extends ConsumerStatefulWidget {
  final int complaintId;

  const ComplaintChatScreen({super.key, required this.complaintId});

  @override
  ConsumerState<ComplaintChatScreen> createState() => _ComplaintChatScreenState();
}

class _ComplaintChatScreenState extends ConsumerState<ComplaintChatScreen> {
  Timer? _timer;
  bool _loading = true;
  List<ComplaintMessageDto> _messages = const [];
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refresh(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh({bool silent = false}) async {
    try {
      if (!silent) setState(() => _loading = true);
      final svc = ref.read(_complaintsServiceProvider);
      final msgs = await svc.getMessages(widget.complaintId);
      if (mounted) {
        setState(() {
          _messages = msgs;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted && !silent) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final svc = ref.read(_complaintsServiceProvider);
    await svc.sendMessage(widget.complaintId, text);
    _controller.clear();
    await _refresh(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réclamation')),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final m = _messages[index];
                      final isAdmin = m.senderRole.toUpperCase().contains('ADMIN');
                      return Align(
                        alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(maxWidth: 320),
                          decoration: BoxDecoration(
                            color: isAdmin ? Colors.grey.shade200 : Theme.of(context).colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(m.message),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Votre message…',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
