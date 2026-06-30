import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/providers/event_provider.dart';
import 'package:athidhi/providers/language_provider.dart';
import 'package:athidhi/screens/guest/guest_rsvp_screen.dart';

class WeddingMicrositeScreen extends StatefulWidget {
  const WeddingMicrositeScreen({super.key});

  @override
  State<WeddingMicrositeScreen> createState() =>
      _WeddingMicrositeScreenState();
}

class _WeddingMicrositeScreenState extends State<WeddingMicrositeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _countdownAnim;

  @override
  void initState() {
    super.initState();
    _countdownAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _countdownAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final event = context.watch<EventProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: CustomScrollView(
        slivers: [
          _buildHeroSection(event, lang),
          _buildCountdownSection(event, lang),
          _buildEventDetailsSection(event, lang),
          _buildActionsSection(lang, event),
          _buildFooterSection(lang),
        ],
      ),
    );
  }

  Widget _buildHeroSection(EventProvider event, LanguageProvider lang) {
    final groom = event.groomName;
    final bride = event.brideName;

    return SliverAppBar(
      expandedHeight: 340,
      pinned: false,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryDark,
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    lang.t('💍 വിവാഹ ക്ഷണം', '💍 Wedding Invitation'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 24),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFFCE4B3)],
                  ).createShader(bounds),
                  child: Text(
                    groom,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                Text(
                  lang.t('ഒപ്പം', '&'),
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFCE4B3), Colors.white],
                  ).createShader(bounds),
                  child: Text(
                    bride,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDividerLine(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.favorite,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 18),
                    ),
                    _buildDividerLine(),
                  ],
                ),
                const SizedBox(height: 12),
                if (event.date.isNotEmpty)
                  Text(
                    event.date,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDividerLine() {
    return Container(
      width: 40,
      height: 1,
      color: Colors.white.withValues(alpha: 0.4),
    );
  }

  Widget _buildCountdownSection(
      EventProvider event, LanguageProvider lang) {
    final days = event.daysLeft;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.schedule, color: AppColors.gold, size: 28),
            const SizedBox(height: 8),
            Text(
              days > 0
                  ? lang.t('വിവാഹത്തിലേക്ക്', 'Counting down to the big day')
                  : lang.t('വിവാഹ ദിനം 🎉', 'Wedding day 🎉'),
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _countdownBlock(
                    days, lang.t('ദിവസം', 'Days'), AppColors.primary),
                const SizedBox(width: 12),
                _countdownBlock(
                    0, lang.t('മണിക്കൂർ', 'Hours'), AppColors.gold),
                const SizedBox(width: 12),
                _countdownBlock(
                    0, lang.t('മിനിറ്റ്', 'Mins'), AppColors.gold),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _countdownBlock(int value, String label, Color color) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _countdownAnim,
            builder: (_, child) => Text(
              '$value',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailsSection(
      EventProvider event, LanguageProvider lang) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
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
                  child: const Icon(Icons.info_outline,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  lang.t('വിവരങ്ങൾ', 'Event Details'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _detailRow(
              Icons.calendar_today_outlined,
              lang.t('തീയതി', 'Date'),
              event.date.isNotEmpty ? event.date : '--',
              AppColors.primary,
            ),
            const SizedBox(height: 14),
            _detailRow(
              Icons.access_time,
              lang.t('മുഹൂർത്തം', 'Muhurtham'),
              event.muhurtham.isNotEmpty ? event.muhurtham : '--',
              AppColors.gold,
            ),
            const SizedBox(height: 14),
            _detailRow(
              Icons.location_on_outlined,
              lang.t('വേദി', 'Venue'),
              event.venue.isNotEmpty ? event.venue : '--',
              Colors.redAccent,
            ),
            if (event.venueLat != 10.5276 || event.venueLng != 76.2144) ...[
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => _openMaps(event.venueLat, event.venueLng),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.green.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map_outlined,
                          color: Colors.green, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        lang.t('Google മാപ്പിൽ കാണുക',
                            'View on Google Maps'),
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(
      LanguageProvider lang, EventProvider event) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.link,
                      color: Colors.green, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  lang.t('പ്രവർത്തനങ്ങൾ', 'Quick Actions'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _actionButton(
              icon: Icons.check_circle_outline,
              label: lang.t('RSVP ചെയ്യുക', 'RSVP Now'),
              color: AppColors.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const GuestRsvpScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _actionButton(
              icon: Icons.live_tv_outlined,
              label: lang.t('തത്സമയം കാണുക', 'Watch Live'),
              color: Colors.redAccent,
              onTap: () {
                if (event.livestreamUrl.isNotEmpty) {
                  _launchUrl(event.livestreamUrl);
                }
              },
            ),
            const SizedBox(height: 10),
            _actionButton(
              icon: Icons.photo_library_outlined,
              label: lang.t('മെമ്മറി വാൾ', 'Memory Wall'),
              color: AppColors.gold,
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _actionButton(
              icon: Icons.favorite_outline,
              label: lang.t('മൊഴ്ദ് അയക്കുക', 'Send Gift'),
              color: Colors.pinkAccent,
              onTap: () {
                if (event.upiId.isNotEmpty) {
                  _launchUrl('upi://pay?pa=${event.upiId}');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterSection(LanguageProvider lang) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.06),
              AppColors.gold.withValues(alpha: 0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            const Text('🙏', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              lang.t(
                'നിങ്ങളുടെ സാന്നിധ്യം ഞങ്ങൾക്ക് വിലപ്പെട്ടതാണ്',
                'Your presence is our greatest gift',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              lang.t(
                'നിങ്ങളുടെ സ്നേഹവും ആശംസകളും ഞങ്ങൾക്ക് വളരെ വിലപ്പെട്ടതാണ്. ഈ പ്രത്യേക ദിവസം നിങ്ങളോടൊപ്പം ആഘോഷിക്കാൻ കാത്തിരിക്കുന്നു.',
                'Your love and blessings mean the world to us. We can\'t wait to celebrate this special day with you.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.share_outlined,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    lang.t('ക്ഷണം ഷെയർ ചെയ്യുക', 'Share Invitation'),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openMaps(double lat, double lng) {
    _launchUrl('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
