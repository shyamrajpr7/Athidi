import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/providers/guest_provider.dart';
import 'package:athidhi/providers/language_provider.dart';
import 'package:athidhi/providers/seating_provider.dart';

class MySeatingScreen extends StatelessWidget {
  final String guestId;

  const MySeatingScreen({super.key, required this.guestId});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final seating = context.watch<SeatingProvider>();
    final guests = context.watch<GuestProvider>();
    final guest = guests.guests.where((g) => g.id == guestId).firstOrNull;

    if (guest == null) {
      return Scaffold(
        appBar: AppBar(title: Text(lang.t('എന്റെ സീറ്റ്', 'My Seat'))),
        body: const Center(child: Text('Guest not found')),
      );
    }

    final tableId = seating.findTableForGuest(guestId);
    final table = tableId != null ? seating.getTableById(tableId) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(lang.t('എന്റെ സീറ്റ്', 'My Seat')),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${guest.groupEmoji} ${guest.name}',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (table != null) ...[
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: table.color.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: table.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.table_restaurant,
                            color: table.color, size: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        lang.t('നിങ്ങൾ ഇരിക്കുന്നത്', 'You are seated at'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        table.label,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${table.filledCount} ${lang.t('അതിഥികൾ', 'guests')}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.event_seat_outlined,
                          size: 64,
                          color:
                              AppColors.textMuted.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text(
                        lang.t('ഇതുവരെ സീറ്റ് നിശ്ചയിച്ചിട്ടില്ല',
                            'Seat not assigned yet'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lang.t('ഹോസ്റ്റ് ഉടൻ സീറ്റ് നിശ്ചയിക്കും',
                            'Host will assign your seat soon'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
              Text(
                '🙏',
                style: TextStyle(
                  fontSize: 32,
                  color: AppColors.textMuted.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
