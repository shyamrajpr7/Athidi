import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/providers/livestream_provider.dart';
import 'package:athidhi/providers/language_provider.dart';

class LiveTelecastScreen extends StatefulWidget {
  final String eventId;
  final String groomName;
  final String brideName;

  const LiveTelecastScreen({
    super.key,
    required this.eventId,
    this.groomName = '',
    this.brideName = '',
  });

  @override
  State<LiveTelecastScreen> createState() => _LiveTelecastScreenState();
}

class _LiveTelecastScreenState extends State<LiveTelecastScreen>
    with SingleTickerProviderStateMixin {
  final _wishNameController = TextEditingController();
  final _wishMsgController = TextEditingController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LivestreamProvider>();
      provider.loadStream(widget.eventId);
      provider.subscribeToWishes(widget.eventId);
      provider.loadWishes(widget.eventId);
    });
  }

  @override
  void dispose() {
    _wishNameController.dispose();
    _wishMsgController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final provider = context.watch<LivestreamProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          lang.t('തത്സമയ സംപ്രേഷണം', 'Live Telecast'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          if (provider.isLive)
            _buildLiveBadge(),
        ],
      ),
      body: Column(
        children: [
          if (provider.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else if (provider.streamUrl.isEmpty)
            _buildNoStream(lang)
          else if (provider.status == StreamStatus.scheduled &&
              provider.countdown != null &&
              provider.countdown!.inSeconds > 0)
            _buildCountdown(lang, provider)
          else
            Expanded(
              child: _buildStreamView(lang, provider),
            ),
          if (provider.streamUrl.isNotEmpty)
            _buildWishSection(lang, provider),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_pulseController),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fiber_manual_record, size: 10, color: Colors.white),
            SizedBox(width: 4),
            Text('LIVE',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildNoStream(LanguageProvider lang) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.live_tv,
                size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              lang.t('തത്സമയ സംപ്രേഷണം ഇതുവരെ ലഭ്യമല്ല',
                  'Live stream not available yet'),
              style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              lang.t('വിവാഹ ദിവസം തത്സമയം കാണാം',
                  'Available on the wedding day'),
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdown(LanguageProvider lang, LivestreamProvider provider) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 3),
              ),
              child: Column(
                children: [
                  Text(
                    _formatCountdown(provider.countdown!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lang.t('ബാക്കി', 'remaining'),
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              lang.t('തത്സമയ സംപ്രേഷണം ആരംഭിക്കും', 'Live stream will begin'),
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.groomName} & ${widget.brideName}',
              style: TextStyle(
                color: AppColors.gold.withValues(alpha: 0.8),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamView(LanguageProvider lang, LivestreamProvider provider) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(provider.streamUrl));

    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (provider.status == StreamStatus.ended)
          Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 48, color: Colors.white54),
                  const SizedBox(height: 12),
                  Text(
                    lang.t('സംപ്രേഷണം അവസാനിച്ചു', 'Stream ended'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lang.t('വിവാഹ ഫോട്ടോകൾ മെമ്മറി വാളിൽ കാണുക',
                        'View wedding photos on the Memory Wall'),
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _launchExternally(provider.streamUrl),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.open_in_new,
                  color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWishSection(LanguageProvider lang, LivestreamProvider provider) {
    final wishes = provider.approvedWishes;

    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 16),
                const SizedBox(width: 6),
                Text(
                  lang.t('ആശംസകൾ', 'Wishes'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                Text(
                  '${wishes.length}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: wishes.isEmpty
                ? Center(
                    child: Text(
                      lang.t('ആദ്യ ആശംസ അയക്കൂ! 🎉',
                          'Send the first wish! 🎉'),
                      style:
                          const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: wishes.length,
                    itemBuilder: (_, i) {
                      final w = wishes[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.1),
                              child: Text(
                                w.guestName.isNotEmpty
                                    ? w.guestName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    w.guestName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    w.message,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textDark),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                  top: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _wishNameController,
                      decoration: InputDecoration(
                        hintText: lang.t('പേര്', 'Name'),
                        hintStyle: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _wishMsgController,
                      decoration: InputDecoration(
                        hintText: lang.t('ആശംസ...', 'Your wish...'),
                        hintStyle: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 12),
                      onSubmitted: (_) => _sendWish(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendWish(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendWish(BuildContext context) {
    final name = _wishNameController.text.trim();
    final msg = _wishMsgController.text.trim();
    if (name.isEmpty || msg.isEmpty) return;

    context.read<LivestreamProvider>().sendWish(
          eventId: widget.eventId,
          guestName: name,
          message: msg,
        );

    _wishMsgController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.read<LanguageProvider>().t('ആശംസ അയച്ചു! 🎉', 'Wish sent! 🎉'),
        ),
        backgroundColor: AppColors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _launchExternally(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatCountdown(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
