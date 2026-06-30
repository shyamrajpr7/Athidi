import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/providers/event_provider.dart';
import 'package:athidhi/providers/language_provider.dart';
import 'package:athidhi/screens/microsite/wedding_microsite_screen.dart';

class HostMicrositeScreen extends StatefulWidget {
  const HostMicrositeScreen({super.key});

  @override
  State<HostMicrositeScreen> createState() => _HostMicrositeScreenState();
}

class _HostMicrositeScreenState extends State<HostMicrositeScreen> {
  bool _micrositeEnabled = true;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final event = context.watch<EventProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('മൈക്രോസൈറ്റ്', 'Wedding Microsite')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            tooltip: lang.t('പ്രിവ്യൂ', 'Preview'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const WeddingMicrositeScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(event, lang),
            const SizedBox(height: 20),
            _buildToggleSection(event, lang),
            const SizedBox(height: 20),
            _buildShareSection(event, lang),
            const SizedBox(height: 20),
            _buildPreviewSection(event, lang),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(EventProvider event, LanguageProvider lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('💒', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            '${event.groomName} & ${event.brideName}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lang.t('വിവാഹ മൈക്രോസൈറ്റ്', 'Wedding Microsite'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSection(EventProvider event, LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.toggle_on_outlined,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  lang.t('മൈക്രോസൈറ്റ് ലഭ്യമാണ്',
                      'Microsite Available'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Switch(
                value: _micrositeEnabled,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => setState(() => _micrositeEnabled = val),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            lang.t(
              'ഓൺ ചെയ്യുമ്പോൾ, നിങ്ങളുടെ വിവാഹ വിവരങ്ങൾ ഉൾപ്പെടുന്ന ഒരു മനോഹരമായ പേജ് അതിഥികൾക്ക് കാണാനാകും.',
              'When enabled, guests can view a beautiful page with all your wedding details.',
            ),
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildShareSection(EventProvider event, LanguageProvider lang) {
    final text = _buildShareText(event, lang);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.share_outlined,
                    color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                lang.t('ക്ഷണം ഷെയർ ചെയ്യുക', 'Share Invitation'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(lang.t(
                            'ക്ലിപ്പ്ബോർഡിൽ പകർത്തി',
                            'Copied to clipboard!')),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.copy, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          lang.t('പകർത്തുക', 'Copy'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(lang.t(
                            'പകർത്തി, വാട്ട്സ്ആപ്പിൽ ഒട്ടിക്കുക',
                            'Copied! Paste in WhatsApp')),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          lang.t('വാട്ട്സ്ആപ്പ്', 'WhatsApp'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              lang.t(
                'മുകളിലുള്ള ടെക്സ്റ്റ് പകർത്തി നിങ്ങളുടെ അതിഥികൾക്ക് അയക്കുക',
                'Copy the text above and send it to your guests',
              ),
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(EventProvider event, LanguageProvider lang) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const WeddingMicrositeScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.04),
              AppColors.gold.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.open_in_new,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.t('മൈക്രോസൈറ്റ് പ്രിവ്യൂ', 'Preview Microsite'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lang.t(
                      'നിങ്ങളുടെ അതിഥികൾക്ക് ഇത് എങ്ങനെ കാണപ്പെടും എന്ന് കാണുക',
                      'See how your microsite looks to guests',
                    ),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: AppColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }

  String _buildShareText(EventProvider event, LanguageProvider lang) {
    final isEn = !context.read<LanguageProvider>().isMalayalam;
    final groom = event.groomName;
    final bride = event.brideName;
    final date = event.date;
    final muhurtham = event.muhurtham;
    final venue = event.venue;

    if (isEn) {
      return '💒 Wedding Invitation\n\n'
          '$groom & $bride\n'
          'request the pleasure of your company\n\n'
          '📅 Date: $date\n'
          '⏰ Muhurtham: $muhurtham\n'
          '📍 Venue: $venue\n\n'
          'Your presence is our greatest gift 🙏';
    } else {
      return '💒 വിവാഹ ക്ഷണം\n\n'
          '$groom & $bride\n'
          'നിങ്ങളുടെ സാന്നിധ്യം ഞങ്ങൾക്ക് വിലപ്പെട്ടതാണ്\n\n'
          '📅 തീയതി: $date\n'
          '⏰ മുഹൂർത്തം: $muhurtham\n'
          '📍 വേദി: $venue\n\n'
          'നിങ്ങളുടെ സാന്നിധ്യമാണ് ഞങ്ങൾക്ക് ഏറ്റവും വലിയ സമ്മാനം 🙏';
    }
  }
}
