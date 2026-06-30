import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/models/guest_model.dart';
import 'package:athidhi/models/reminder_template.dart';
import 'package:athidhi/providers/guest_provider.dart';
import 'package:athidhi/providers/event_provider.dart';
import 'package:athidhi/providers/language_provider.dart';
import 'package:athidhi/providers/reminder_provider.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _selected = {};
  ReminderTemplate? _selectedTemplate;
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().loadTemplates();
      final eventId = context.read<EventProvider>().eventId;
      if (eventId != null) {
        context.read<ReminderProvider>().loadHistory(eventId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final guests = context.watch<GuestProvider>();
    final reminder = context.watch<ReminderProvider>();
    final event = context.watch<EventProvider>();

    final pendingGuests = reminder.getPendingGuests(guests.guests);

    if (_selectedTemplate == null && reminder.templates.isNotEmpty) {
      _selectedTemplate = reminder.templates.first;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          lang.t('RSVP ഓർമ്മപ്പെടുത്തലുകൾ', 'RSVP Reminders'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          tabs: [
            Tab(text: lang.t('ഓർമ്മപ്പെടുത്തുക', 'Remind')),
            Tab(text: lang.t('ചരിത്രം', 'History')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRemindTab(lang, pendingGuests, reminder, event, guests),
          _buildHistoryTab(lang, reminder),
        ],
      ),
    );
  }

  Widget _buildRemindTab(
    LanguageProvider lang,
    List<Guest> pendingGuests,
    ReminderProvider reminder,
    EventProvider event,
    GuestProvider guests,
  ) {
    return Column(
      children: [
        if (pendingGuests.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 64, color: AppColors.green),
                  const SizedBox(height: 16),
                  Text(
                    lang.t('എല്ലാവരും RSVP ചെയ്തു! 🎉',
                        'Everyone has RSVP\'d! 🎉'),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark),
                  ),
                ],
              ),
            ),
          )
        else ...[
          _buildSelectionBar(lang, pendingGuests, reminder, event, guests),
          Expanded(child: _buildGuestList(lang, pendingGuests)),
          _buildSendBar(lang, reminder, event),
        ],
      ],
    );
  }

  Widget _buildSelectionBar(
    LanguageProvider lang,
    List<Guest> pendingGuests,
    ReminderProvider reminder,
    EventProvider event,
    GuestProvider guests,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${pendingGuests.length} ${lang.t('പേർ RSVP ചെയ്തിട്ടില്ല', 'haven\'t RSVP\'d')}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectAll = !_selectAll;
                    if (_selectAll) {
                      _selected.addAll(pendingGuests.map((g) => g.id));
                    } else {
                      _selected.clear();
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _selectAll
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    _selectAll
                        ? lang.t('തിരഞ്ഞെടുപ്പ് മാറ്റുക', 'Deselect All')
                        : lang.t('എല്ലാം തിരഞ്ഞെടുക്കുക', 'Select All'),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            lang.t('ടെംപ്ലേറ്റ് തിരഞ്ഞെടുക്കുക', 'Choose template'),
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: reminder.templates.length,
              itemBuilder: (_, i) {
                final t = reminder.templates[i];
                final selected = _selectedTemplate?.id == t.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTemplate = t),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      t.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: selected
                            ? Colors.white
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestList(LanguageProvider lang, List<Guest> pendingGuests) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: pendingGuests.length,
      itemBuilder: (_, i) {
        final guest = pendingGuests[i];
        final isSelected = _selected.contains(guest.id);
        final reminderCount =
            context.read<ReminderProvider>().getGuestHistory(guest.id).length;

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selected.remove(guest.id);
                _selectAll = false;
              } else {
                _selected.add(guest.id);
                if (_selected.length == pendingGuests.length) {
                  _selectAll = true;
                }
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.06)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check,
                          size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    guest.initials,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(guest.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Row(
                        children: [
                          Text(guest.group,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textMuted)),
                          if (reminderCount > 0) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.notifications_none,
                                size: 12,
                                color: AppColors.textMuted.withValues(alpha: 0.6)),
                            const SizedBox(width: 2),
                            Text('$reminderCount',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusBgColor(guest.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _shortStatus(guest.status, lang.isMalayalam),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(guest.status)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSendBar(
    LanguageProvider lang,
    ReminderProvider reminder,
    EventProvider event,
  ) {
    final count = _selected.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: count == 0
                    ? null
                    : () => _sendBulk(
                          context,
                          reminder,
                          event,
                          'whatsapp',
                        ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: count > 0
                        ? const Color(0xFF25D366)
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        count > 0
                            ? 'WhatsApp ($count)'
                            : lang.t('തിരഞ്ഞെടുക്കുക', 'Select guests'),
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
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: count == 0
                    ? null
                    : () => _sendBulk(
                          context,
                          reminder,
                          event,
                          'sms',
                        ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: count > 0
                        ? AppColors.primary
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sms, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        count > 0
                            ? 'SMS ($count)'
                            : lang.t('എസ്‌എം‌എസ്', 'SMS'),
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
      ),
    );
  }

  Widget _buildHistoryTab(LanguageProvider lang, ReminderProvider reminder) {
    if (reminder.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 64, color: AppColors.border),
            const SizedBox(height: 16),
            Text(
              lang.t('ഇതുവരെ ഓർമ്മപ്പെടുത്തലുകൾ ഒന്നുമില്ല',
                  'No reminders sent yet'),
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: reminder.history.length,
      itemBuilder: (_, i) {
        final log = reminder.history[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: log.channel == 'whatsapp'
                      ? const Color(0xFF25D366).withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  log.channel == 'whatsapp'
                      ? Icons.chat
                      : Icons.sms,
                  color: log.channel == 'whatsapp'
                      ? const Color(0xFF25D366)
                      : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log.guestName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(log.sentAt, lang.isMalayalam),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: log.status == 'sent'
                      ? AppColors.green.withValues(alpha: 0.1)
                      : Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  log.status == 'sent'
                      ? (lang.isMalayalam ? 'അയച്ചു' : 'Sent')
                      : (lang.isMalayalam ? 'പരാജയം' : 'Failed'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: log.status == 'sent'
                        ? AppColors.green
                        : Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendBulk(
    BuildContext context,
    ReminderProvider reminder,
    EventProvider event,
    String channel,
  ) async {
    if (_selectedTemplate == null) return;
    final guests = context.read<GuestProvider>().guests;
    final selectedGuests = guests.where((g) => _selected.contains(g.id)).toList();

    for (final guest in selectedGuests) {
      if (channel == 'whatsapp') {
        await reminder.sendWhatsApp(
          guest: guest,
          template: _selectedTemplate!,
          groom: event.groomName,
          bride: event.brideName,
          date: event.date,
          venue: event.venue,
          isMalayalam: context.read<LanguageProvider>().isMalayalam,
          eventId: event.eventId,
        );
      } else {
        await reminder.sendSms(
          guest: guest,
          template: _selectedTemplate!,
          groom: event.groomName,
          bride: event.brideName,
          date: event.date,
          venue: event.venue,
          isMalayalam: context.read<LanguageProvider>().isMalayalam,
          eventId: event.eventId,
        );
      }
    }

    if (mounted) {
      setState(() {
        _selected.clear();
        _selectAll = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            channel == 'whatsapp'
                ? '${selectedGuests.length} ${context.read<LanguageProvider>().isMalayalam ? 'പേർക്ക് WhatsApp അയച്ചു' : 'WhatsApp messages opened'}'
                : '${selectedGuests.length} ${context.read<LanguageProvider>().isMalayalam ? 'പേർക്ക് SMS അയച്ചു' : 'SMS messages opened'}',
          ),
          backgroundColor: AppColors.green,
        ),
      );
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'accepted':
        return AppColors.green.withValues(alpha: 0.1);
      case 'declined':
        return Colors.redAccent.withValues(alpha: 0.1);
      case 'viewed':
        return AppColors.primary.withValues(alpha: 0.1);
      default:
        return Colors.orange.withValues(alpha: 0.1);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppColors.green;
      case 'declined':
        return Colors.redAccent;
      case 'viewed':
        return AppColors.primary;
      default:
        return Colors.orange;
    }
  }

  String _shortStatus(String status, bool isMl) {
    switch (status) {
      case 'accepted':
        return isMl ? 'ഉണ്ട്' : 'Yes';
      case 'declined':
        return isMl ? 'ഇല്ല' : 'No';
      case 'viewed':
        return isMl ? 'കണ്ടു' : 'Viewed';
      default:
        return isMl ? 'ഇല്ല' : 'No';
    }
  }

  String _formatDate(DateTime dt, bool isMl) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
