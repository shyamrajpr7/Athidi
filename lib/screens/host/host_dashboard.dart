import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/providers/auth_provider.dart';
import 'package:athidhi/providers/event_provider.dart';
import 'package:athidhi/providers/guest_provider.dart';
import 'package:athidhi/providers/language_provider.dart';
import 'package:athidhi/screens/auth/login_screen.dart';
import 'package:athidhi/screens/guest/guest_rsvp_screen.dart';
import 'package:athidhi/screens/host/guest_list_screen.dart';
import 'package:athidhi/screens/host/invitation_screen.dart';
import 'package:athidhi/screens/host/event_setup_screen.dart';
import 'package:athidhi/screens/memory/memory_wall_screen.dart';
import 'package:athidhi/screens/host/reminder_screen.dart';
import 'package:athidhi/screens/host/stream_management_screen.dart';
import 'package:athidhi/screens/microsite/host_microsite_screen.dart';
import 'package:athidhi/screens/host/seating_chart_screen.dart';
import 'package:athidhi/providers/livestream_provider.dart';
class HostDashboard extends StatefulWidget {
  const HostDashboard({super.key});

  @override
  State<HostDashboard> createState() => _HostDashboardState();
}

class _HostDashboardState extends State<HostDashboard> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final eventProvider = context.read<EventProvider>();
      await eventProvider.loadEvent();
      if (mounted && eventProvider.eventId != null) {
        context.read<GuestProvider>().loadGuests(eventProvider.eventId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final event = context.watch<EventProvider>();
    final guests = context.watch<GuestProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(lang, event, guests),
            _buildTabs(lang),
            Expanded(
              child: _selectedTab == 0
                  ? _buildOverview(lang, guests, event)
                  : _selectedTab == 1
                      ? GuestListScreen(isMalayalam: lang.isMalayalam)
                      : InvitationScreen(isMalayalam: lang.isMalayalam),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'preview',
            mini: true,
            backgroundColor: AppColors.surface,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GuestRsvpScreen()),
              );
            },
            child:
                const Icon(Icons.visibility_outlined, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: () {
              if (event.eventId == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EventSetupScreen()),
                );
              }
            },
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: Text(
              lang.t('അതിഥിയെ ചേർക്കുക', 'Add Guest'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      LanguageProvider lang, EventProvider event, GuestProvider guests) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.t('നമസ്കാരം 👋', 'Hello 👋'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.status == EventStatus.loaded
                        ? '${event.groomName} & ${event.brideName} · ${event.daysLeft} ${lang.t('ദിവസം ബാക്കി', 'days left')}'
                        : lang.t('ഇവന്റ് സജ്ജമാക്കുക', 'Setup your event'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => lang.toggleLanguage(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.white.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        lang.isMalayalam ? 'EN' : 'മല',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      await context.read<AuthProvider>().signOut();
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard(
                lang.t('ക്ഷണിച്ചത്', 'Invited'),
                guests.totalInvited.toString(),
                Icons.mail_outline,
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                lang.t('കണ്ടത്', 'Viewed'),
                guests.totalViewed.toString(),
                Icons.visibility_outlined,
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                lang.t('സ്ഥിരീകരിച്ചത്', 'Confirmed'),
                guests.totalAccepted.toString(),
                Icons.check_circle_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(LanguageProvider lang) {
    final tabs = [
      lang.t('അവലോകനം', 'Overview'),
      lang.t('അതിഥികൾ', 'Guests'),
      lang.t('ക്ഷണങ്ങൾ', 'Invitations'),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (i) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTab == i
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color:
                        _selectedTab == i ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverview(LanguageProvider lang, GuestProvider guests, EventProvider event) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(lang.t('RSVP പ്രോഗ്രസ്സ്', 'RSVP Progress')),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildProgressRow(
                  lang.t('സ്ഥിരീകരിച്ചത്', 'Confirmed'),
                  guests.totalAccepted,
                  guests.totalInvited,
                  AppColors.green,
                ),
                const SizedBox(height: 12),
                _buildProgressRow(
                  lang.t('കണ്ടത്', 'Viewed'),
                  guests.totalViewed,
                  guests.totalInvited,
                  AppColors.primary,
                ),
                const SizedBox(height: 12),
                _buildProgressRow(
                  lang.t('നിരസിച്ചത്', 'Declined'),
                  guests.totalDeclined,
                  guests.totalInvited,
                  Colors.redAccent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(
            lang.t('പ്രധാന അതിഥികൾ — RSVP ബാക്കി', 'Priority Guests — Pending'),
          ),
          const SizedBox(height: 12),
          if (guests.priorityPendingGuests.isEmpty)
            Center(
              child: Text(
                lang.t('എല്ലാ പ്രധാന അതിഥികളും RSVP ചെയ്തു ✅',
                    'All priority guests have RSVP\'d ✅'),
                style: const TextStyle(color: AppColors.green, fontSize: 13),
              ),
            )
          else
            ...guests.priorityPendingGuests.map((g) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(g.initials,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(g.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            Text(g.group,
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          lang.t('ബാക്കി', 'Pending'),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                )),
          const SizedBox(height: 20),
          _buildReminderCard(lang, guests),
          const SizedBox(height: 12),
          _buildStreamCard(lang, event),
          const SizedBox(height: 12),
          _buildMemoryWallCard(lang, event),
          const SizedBox(height: 12),
          _buildMicrositeCard(lang),
          const SizedBox(height: 12),
          _buildSeatingCard(lang),
          const SizedBox(height: 20),
          _buildSectionTitle(lang.t('സദ്യ എണ്ണം', 'Sadhya Headcount')),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('🍌', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  guests.totalHeadcount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  lang.t('പ്ലേറ്റ് ഒരുക്കേണ്ടത്', 'plates to prepare'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, int value, int total, Color color) {
    final percent = total > 0 ? value / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.textMuted)),
            Text('$value / $total',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent.toDouble(),
            backgroundColor: AppColors.border,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStreamCard(LanguageProvider lang, EventProvider event) {
    final stream = context.watch<LivestreamProvider>();
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const StreamManagementScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: stream.isLive
                ? Colors.red.withValues(alpha: 0.3)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: stream.isLive
                    ? Colors.red.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                stream.isLive
                    ? Icons.fiber_manual_record
                    : Icons.live_tv_outlined,
                color: stream.isLive ? Colors.red : AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stream.isLive
                        ? lang.t('തത്സമയ സംപ്രേഷണം', 'Live Streaming')
                        : lang.t('തത്സമയ സംപ്രേഷണം', 'Live Stream'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stream.isLive
                        ? lang.t('തത്സമയ സംപ്രേഷണം നടക്കുന്നു 🔴',
                            'Currently live 🔴')
                        : lang.t(
                            'സ്ട്രീം സജ്ജമാക്കുക', 'Configure stream'),
                    style: TextStyle(
                      fontSize: 12,
                      color: stream.isLive
                          ? Colors.red
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: AppColors.textMuted.withValues(alpha: 0.5),
                size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(LanguageProvider lang, GuestProvider guests) {
    final pending = guests.guests
        .where((g) => g.status != 'accepted' && g.status != 'declined')
        .length;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ReminderScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications_active_outlined,
                  color: Colors.orange, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.t('RSVP ഓർമ്മപ്പെടുത്തലുകൾ', 'RSVP Reminders'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pending > 0
                        ? lang.t(
                            '$pending പേർ ഇതുവരെ RSVP ചെയ്തിട്ടില്ല',
                            '$pending guests haven\'t RSVP\'d',
                          )
                        : lang.t(
                            'എല്ലാവരും RSVP ചെയ്തു ✅',
                            'Everyone RSVP\'d ✅',
                          ),
                    style: TextStyle(
                      fontSize: 12,
                      color: pending > 0
                          ? Colors.orange
                          : AppColors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (pending > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$pending',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios,
                color: AppColors.textMuted.withValues(alpha: 0.5), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryWallCard(LanguageProvider lang, EventProvider event) {
    return GestureDetector(
      onTap: () {
        if (event.eventId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MemoryWallScreen(
                eventId: event.eventId!,
                isHost: true,
              ),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.photo_library_outlined,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.t('മെമ്മറി വാൾ', 'Memory Wall'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lang.t(
                      'വിവാഹ ഫോട്ടോകൾ കാണുകയും മോഡറേറ്റ് ചെയ്യുകയും ചെയ്യുക',
                      'View & moderate wedding photos',
                    ),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.6), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMicrositeCard(LanguageProvider lang) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HostMicrositeScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6A1B9A),
              Color(0xFF4A148C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.language_outlined,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.t('വിവാഹ മൈക്രോസൈറ്റ്', 'Wedding Microsite'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lang.t(
                      'വിവാഹ വിവരങ്ങൾ ഷെയർ ചെയ്യുക',
                      'Share your wedding details',
                    ),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.6), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatingCard(LanguageProvider lang) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SeatingChartScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.event_seat_outlined,
                  color: Colors.teal, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.t('സീറ്റിംഗ് ചാർട്ട്', 'Seating Chart'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lang.t(
                      'മേശകൾ സൃഷ്ടിച്ച് അതിഥികളെ നിയോഗിക്കുക',
                      'Create tables & assign guests',
                    ),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: AppColors.textMuted.withValues(alpha: 0.5), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }
}
