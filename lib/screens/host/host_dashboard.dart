import 'package:athidhi/screens/host/guest_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/screens/host/invitation_screen.dart';
import 'package:athidhi/screens/guest/guest_rsvp_screen.dart';

class HostDashboard extends StatefulWidget {
  const HostDashboard({super.key});

  @override
  State<HostDashboard> createState() => _HostDashboardState();
}

class _HostDashboardState extends State<HostDashboard> {
  bool _isMalayalam = true;
  int _selectedTab = 0;

  // Sample data — real data comes from Firestore later
  final int totalInvited = 847;
  final int totalViewed = 612;
  final int totalAccepted = 489;
  final int totalDeclined = 34;

  String get _greetingText =>
      _isMalayalam ? 'നമസ്കാരം, ശ്യാംരാജ് 👋' : 'Hello, Shyamraj 👋';
  String get _eventText =>
      _isMalayalam ? 'വിവാഹം — 12 ദിവസം ബാക്കി' : 'Wedding — 12 days left';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: _selectedTab == 0
                  ? _buildOverview()
                  : _selectedTab == 1
                      ? _buildGuestList()
                      : _buildInvitations(),
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
                MaterialPageRoute(
                  builder: (_) => const GuestRsvpScreen(),
                ),
              );
            },
            child:
                const Icon(Icons.visibility_outlined, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: () {},
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: Text(
              _isMalayalam ? 'അതിഥിയെ ചേർക്കുക' : 'Add Guest',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
                    _greetingText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _eventText,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Language toggle
                  GestureDetector(
                    onTap: () => setState(() => _isMalayalam = !_isMalayalam),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.white.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _isMalayalam ? 'EN' : 'മല',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Text('ശ്യാ',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              _buildStatCard(
                _isMalayalam ? 'ക്ഷണിച്ചത്' : 'Invited',
                totalInvited.toString(),
                Icons.mail_outline,
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                _isMalayalam ? 'കണ്ടത്' : 'Viewed',
                totalViewed.toString(),
                Icons.visibility_outlined,
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                _isMalayalam ? 'സ്ഥിരീകരിച്ചത്' : 'Confirmed',
                totalAccepted.toString(),
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

  Widget _buildTabs() {
    final tabs = _isMalayalam
        ? ['അവലോകനം', 'അതിഥികൾ', 'ക്ഷണങ്ങൾ']
        : ['Overview', 'Guests', 'Invitations'];

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

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          _buildSectionTitle(
              _isMalayalam ? 'RSVP പ്രോഗ്രസ്സ്' : 'RSVP Progress'),
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
                  _isMalayalam ? 'സ്ഥിരീകരിച്ചത്' : 'Confirmed',
                  totalAccepted,
                  totalInvited,
                  AppColors.green,
                ),
                const SizedBox(height: 12),
                _buildProgressRow(
                  _isMalayalam ? 'കണ്ടത്' : 'Viewed',
                  totalViewed,
                  totalInvited,
                  AppColors.primary,
                ),
                const SizedBox(height: 12),
                _buildProgressRow(
                  _isMalayalam ? 'നിരസിച്ചത്' : 'Declined',
                  totalDeclined,
                  totalInvited,
                  Colors.redAccent,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Pending VIP guests
          _buildSectionTitle(_isMalayalam
              ? 'പ്രധാന അതിഥികൾ — RSVP ബാക്കി'
              : 'Priority Guests — Pending RSVP'),
          const SizedBox(height: 12),
          ..._buildPriorityGuests(),

          const SizedBox(height: 20),

          // Sadhya headcount
          _buildSectionTitle(_isMalayalam ? 'സദ്യ എണ്ണം' : 'Sadhya Headcount'),
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
                  totalAccepted.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isMalayalam ? 'പ്ലേറ്റ് ഒരുക്കേണ്ടത്' : 'plates to prepare',
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
    final percent = value / total;
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
            value: percent,
            backgroundColor: AppColors.border,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPriorityGuests() {
    final guests = [
      {'name': 'Rajan Uncle', 'group': 'Close Family', 'status': 'pending'},
      {'name': 'Meera Aunty', 'group': 'Close Family', 'status': 'pending'},
      {'name': 'Dr. Suresh', 'group': 'VIP', 'status': 'viewed'},
    ];
    return guests.map((g) {
      final isPending = g['status'] == 'pending';
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isPending ? Colors.orange.withOpacity(0.4) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                g['name']![0],
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(g['name']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(g['group']!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isPending
                    ? Colors.orange.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isPending
                    ? (_isMalayalam ? 'ബാക്കി' : 'Pending')
                    : (_isMalayalam ? 'കണ്ടു' : 'Viewed'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPending ? Colors.orange : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.send, size: 18, color: AppColors.primary),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildGuestList() {
    return GuestListScreen(isMalayalam: _isMalayalam);
  }

  Widget _buildInvitations() {
    return InvitationScreen(isMalayalam: _isMalayalam);
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
