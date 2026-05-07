import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/auth_provider.dart';

class PartnerLinkScreen extends ConsumerStatefulWidget {
  const PartnerLinkScreen({super.key});

  @override
  ConsumerState<PartnerLinkScreen> createState() => _PartnerLinkScreenState();
}

class _PartnerLinkScreenState extends ConsumerState<PartnerLinkScreen> {
  final _codeCtrl = TextEditingController();
  bool _linking = false;
  String? _linkError;
  String? _linkSuccess;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _linkPartner() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _linkError = 'Enter your partner\'s code.');
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() { _linking = true; _linkError = null; _linkSuccess = null; });

    try {
      final db = FirebaseFirestore.instance;

      // Find partner by share code
      final query = await db
          .collection('users')
          .where('shareCode', isEqualTo: code)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() => _linkError = 'No user found with that code.');
        return;
      }

      final partnerDoc = query.docs.first;
      final partnerUid = partnerDoc.id;

      if (partnerUid == user.uid) {
        setState(() => _linkError = 'That\'s your own code!');
        return;
      }

      // Create mutual link
      final batch = db.batch();
      batch.update(db.collection('users').doc(user.uid), {'partnerUid': partnerUid});
      batch.update(db.collection('users').doc(partnerUid), {'partnerUid': user.uid});
      await batch.commit();

      setState(() => _linkSuccess =
          'Linked with ${partnerDoc['displayName']}! You can now sync schedules.');
      _codeCtrl.clear();
    } catch (e) {
      setState(() => _linkError = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _linking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final myCode = profile?['shareCode'] as String? ?? '——';
    final partnerUid = profile?['partnerUid'] as String?;

    return Scaffold(
      appBar: AppBar(title: const Text('Partner link')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // My share code card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Text('Your share code', style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 14, fontWeight: FontWeight.w500,
                    )),
                    const SizedBox(height: 12),
                    Text(myCode, style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 10,
                      fontFamily: 'monospace',
                    )),
                    const SizedBox(height: 8),
                    Text('Share this with your partner to connect',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        )),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: myCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Code copied!')),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('Copy'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Share.share(
                              'Join me on SyncSpace! Use my code: $myCode'),
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text('Share'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54, width: 1.5),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Current link status
              if (partnerUid != null) ...[
                _StatusCard(
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  title: 'Partner linked',
                  subtitle: 'Your schedules are syncing automatically',
                ),
                const SizedBox(height: 20),
              ],

              // Enter partner code
              Text('Enter partner\'s code', style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: colors.onSurface,
              )),
              const SizedBox(height: 10),
              TextFormField(
                controller: _codeCtrl,
                textCapitalization: TextCapitalization.characters,
                maxLength: 7,
                style: const TextStyle(fontSize: 20, letterSpacing: 5, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'AB-1234',
                  counterText: '',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
                ],
              ),
              const SizedBox(height: 14),

              if (_linkError != null)
                _StatusCard(
                  icon: Icons.error_outline,
                  iconColor: colors.error,
                  title: _linkError!,
                  subtitle: null,
                ),
              if (_linkSuccess != null)
                _StatusCard(
                  icon: Icons.check_circle_outline,
                  iconColor: Colors.green,
                  title: _linkSuccess!,
                  subtitle: null,
                ),
              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: _linking ? null : _linkPartner,
                child: _linking
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Link partner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;

  const _StatusCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Row(children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            )),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: TextStyle(
                fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant,
              )),
            ],
          ],
        )),
      ]),
    );
  }
}
