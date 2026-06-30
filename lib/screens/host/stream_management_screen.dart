import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/providers/event_provider.dart';
import 'package:athidhi/providers/language_provider.dart';
import 'package:athidhi/providers/livestream_provider.dart';

class StreamManagementScreen extends StatefulWidget {
  const StreamManagementScreen({super.key});

  @override
  State<StreamManagementScreen> createState() =>
      _StreamManagementScreenState();
}

class _StreamManagementScreenState extends State<StreamManagementScreen> {
  late TextEditingController _urlController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LivestreamProvider>();
      _urlController.text = provider.streamUrl;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final provider = context.watch<LivestreamProvider>();
    final event = context.watch<EventProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          lang.t('തത്സമയ സംപ്രേഷണം', 'Live Stream'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.t('സ്ട്രീം URL', 'Stream URL'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: 'https://youtube.com/live/...',
                      hintStyle: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _saveUrl(lang, provider, event),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            lang.t('URL സേവ് ചെയ്യുക', 'Save URL'),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.t('സ്ട്രീം സ്റ്റാറ്റസ്', 'Stream Status'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 16),
                _buildStatusButton(
                  label: lang.t('ഷെഡ്യൂൾ ചെയ്തു', 'Scheduled'),
                  icon: Icons.schedule,
                  color: Colors.orange,
                  isActive: provider.status == StreamStatus.scheduled,
                  onTap: () => _setStatus(
                      provider, event, StreamStatus.scheduled),
                ),
                const SizedBox(height: 10),
                _buildStatusButton(
                  label: lang.t('തത്സമയം', 'Live Now'),
                  icon: Icons.fiber_manual_record,
                  color: Colors.red,
                  isActive: provider.status == StreamStatus.live,
                  onTap: () => _setStatus(
                      provider, event, StreamStatus.live),
                ),
                const SizedBox(height: 10),
                _buildStatusButton(
                  label: lang.t('അവസാനിച്ചു', 'Ended'),
                  icon: Icons.check_circle_outline,
                  color: AppColors.textMuted,
                  isActive: provider.status == StreamStatus.ended,
                  onTap: () => _setStatus(
                      provider, event, StreamStatus.ended),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.t('തത്സമയ ആശംസകൾ', 'Live Wishes'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.wishes.length} ${lang.t('ആശംസകൾ ലഭിച്ചു', 'wishes received')}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                if (provider.wishes.isEmpty)
                  Center(
                    child: Text(
                      lang.t('ഇതുവരെ ആശംസകൾ ഒന്നുമില്ല',
                          'No wishes yet'),
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                    ),
                  )
                else
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: provider.wishes.length,
                      itemBuilder: (_, i) {
                        final w = provider.wishes[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(w.guestName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text(w.message,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => provider.deleteWish(w.id),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.delete_outline,
                                      color: Colors.red, size: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : AppColors.border,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isActive ? color : AppColors.textDark,
              ),
            ),
            const Spacer(),
            if (isActive)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _saveUrl(
      LanguageProvider lang, LivestreamProvider provider, EventProvider event) {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _isSaving = true);
    provider.setStreamUrl(url);
    if (event.eventId != null) {
      provider.updateStreamUrl(event.eventId!, url);
    }
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          lang.t('URL സേവ് ചെയ്തു ✅', 'URL saved ✅'),
        ),
        backgroundColor: AppColors.green,
      ),
    );
  }

  void _setStatus(LivestreamProvider provider, EventProvider event,
      StreamStatus status) {
    provider.setStatus(status);
    if (event.eventId != null) {
      provider.updateStreamStatus(event.eventId!, status);
    }
  }
}
