import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/models/guest_model.dart';
import 'package:athidhi/models/seating_table_model.dart';
import 'package:athidhi/providers/guest_provider.dart';
import 'package:athidhi/providers/language_provider.dart';
import 'package:athidhi/providers/seating_provider.dart';

class SeatingChartScreen extends StatefulWidget {
  const SeatingChartScreen({super.key});

  @override
  State<SeatingChartScreen> createState() => _SeatingChartScreenState();
}

class _SeatingChartScreenState extends State<SeatingChartScreen> {
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final seating = context.watch<SeatingProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(lang.t('സീറ്റിംഗ് ചാർട്ട്', 'Seating Chart')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart_outlined),
            tooltip: lang.t('പുതിയ മേശ', 'Add Table'),
            onPressed: () => _showAddTableDialog(context, lang, seating),
          ),
          if (seating.tables.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: lang.t('എല്ലാം മായ്ക്കുക', 'Clear All'),
              onPressed: () => _confirmClearAll(context, lang, seating),
            ),
        ],
      ),
      body: seating.tables.isEmpty
          ? _buildEmptyState(lang)
          : _buildChart(context, lang, seating),
    );
  }

  Widget _buildEmptyState(LanguageProvider lang) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_seat_outlined,
              size: 80, color: AppColors.textMuted.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            lang.t('ഇതുവരെ മേശകളൊന്നും ചേർത്തിട്ടില്ല',
                'No tables added yet'),
            style: const TextStyle(
                fontSize: 16, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Text(
            lang.t('മുകളിൽ വലതുവശത്തുള്ള + ബട്ടൺ ഉപയോഗിച്ച് മേശകൾ ചേർക്കുക',
                'Tap the + button above to add tables'),
            style: const TextStyle(
                fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(
      BuildContext context, LanguageProvider lang, SeatingProvider seating) {
    final guests = context.watch<GuestProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(lang, seating),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: seating.tables
                .map((table) => _buildTableCard(
                    context, lang, table, guests))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(LanguageProvider lang, SeatingProvider seating) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_seat,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.t('മേശകൾ', 'Tables'),
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  '${seating.tables.length} ${lang.t('മേശകൾ', 'tables')} · '
                  '${seating.totalFilled}/${seating.totalCapacity} '
                  '${lang.t('സീറ്റുകൾ', 'seats')}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(BuildContext context, LanguageProvider lang,
      SeatingTableModel table, GuestProvider guests) {
    final assignedGuests = table.guestIds
        .map((id) => guests.guests.where((g) => g.id == id).firstOrNull)
        .whereType<Guest>()
        .toList();

    return GestureDetector(
      onTap: () => _showTableDetail(
          context, lang, table, guests, assignedGuests),
      child: Container(
        width: (MediaQuery.of(context).size.width - 44) / 2,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: table.isFull
                ? AppColors.green.withValues(alpha: 0.4)
                : AppColors.border,
            width: table.isFull ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: table.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${table.filledCount}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: table.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    table.label,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: table.capacity > 0
                    ? table.filledCount / table.capacity
                    : 0,
                backgroundColor: AppColors.border,
                color: table.isFull ? AppColors.green : table.color,
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${table.filledCount}/${table.capacity}',
              style: TextStyle(
                fontSize: 11,
                color: table.isFull
                    ? AppColors.green
                    : AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (assignedGuests.isNotEmpty) ...[
              const SizedBox(height: 6),
              ...assignedGuests.take(3).map(
                    (g) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        children: [
                          Text(g.groupEmoji, style: const TextStyle(fontSize: 10)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              g.name,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (assignedGuests.length > 3)
                Text(
                  '+${assignedGuests.length - 3} ${lang.t('കൂടുതൽ', 'more')}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showTableDetail(
    BuildContext context,
    LanguageProvider lang,
    SeatingTableModel table,
    GuestProvider guests,
    List<Guest> assignedGuests,
  ) {
    final seating = context.read<SeatingProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final currentTable = seating.getTableById(table.id);
            if (currentTable == null) {
              return const SizedBox.shrink();
            }
            final currentGuests = currentTable.guestIds
                .map((id) => guests.guests.where((g) => g.id == id).firstOrNull)
                .whereType<Guest>()
                .toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: DraggableScrollableSheet(
                initialChildSize: 0.7,
                minChildSize: 0.4,
                maxChildSize: 0.9,
                expand: false,
                builder: (_, scrollController) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView(
                      controller: scrollController,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: currentTable.color
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.table_restaurant,
                                  color: currentTable.color, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentTable.label,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${currentTable.filledCount}/${currentTable.capacity} '
                                    '${lang.t('സീറ്റുകൾ', 'seats')}'
                                    '${currentTable.isFull ? ' · ${lang.t('നിറഞ്ഞു', 'Full')}' : ''}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: currentTable.isFull
                                          ? AppColors.green
                                          : AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  size: 20),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _showEditTableDialog(
                                    context, lang, seating, currentTable);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 20, color: Colors.redAccent),
                              onPressed: () {
                                seating.removeTable(currentTable.id);
                                Navigator.pop(ctx);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang.t('അതിഥികൾ', 'Guests'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            if (!currentTable.isFull)
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _showGuestSelector(context, lang,
                                      seating, currentTable, guests);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.person_add,
                                          size: 14,
                                          color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        lang.t('ചേർക്കുക', 'Add'),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (currentGuests.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                lang.t('ഈ മേശയിൽ ഇതുവരെ ആരുമില്ല',
                                    'No guests assigned yet'),
                                style: const TextStyle(
                                    color: AppColors.textMuted),
                              ),
                            ),
                          )
                        else
                          ...currentGuests.map((g) => Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Text(g.groupEmoji,
                                        style:
                                            const TextStyle(fontSize: 16)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        g.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      g.group,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        seating.unassignGuest(g.id);
                                        setSheetState(() {});
                                      },
                                      child: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              )),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showGuestSelector(
    BuildContext context,
    LanguageProvider lang,
    SeatingProvider seating,
    SeatingTableModel table,
    GuestProvider guests,
  ) {
    final allGuests = guests.guests;
    final unassigned = allGuests
        .where((g) => seating.findTableForGuest(g.id) == null)
        .toList();
    final assignedToOther = allGuests
        .where((g) =>
            seating.findTableForGuest(g.id) != null &&
            seating.findTableForGuest(g.id) != table.id)
        .toList();
    final atThisTable = table.guestIds
        .map((id) => guests.guests.where((g) => g.id == id).firstOrNull)
        .whereType<Guest>()
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${lang.t('അതിഥികളെ ചേർക്കുക', 'Add Guests to')} ${table.label}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${table.filledCount}/${table.capacity} ${lang.t('സീറ്റുകൾ', 'seats')}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (unassigned.isNotEmpty) ...[
                    Text(
                      lang.t('നിയോഗിക്കാത്ത അതിഥികൾ',
                          'Unassigned Guests'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          ...unassigned
                              .map((g) => _guestTile(
                                  ctx, lang, g, seating, table.id,
                                  isAssigned: false))
                              .toList(),
                          if (atThisTable.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              lang.t('ഈ മേശയിലുള്ളത്', 'At this table'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...atThisTable
                                .map((g) => _guestTile(
                                    ctx, lang, g, seating, table.id,
                                    isAssigned: true))
                                .toList(),
                          ],
                          if (assignedToOther.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              lang.t('മറ്റ് മേശകളിലുള്ളത്',
                                  'At other tables'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...assignedToOther
                                .map((g) => _guestTile(
                                    ctx, lang, g, seating, table.id,
                                    isAssigned: false,
                                    canAssign: false))
                                .toList(),
                          ],
                        ],
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                size: 48,
                                color:
                                    AppColors.green.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            Text(
                              lang.t('എല്ലാ അതിഥികളെയും നിയോഗിച്ചു',
                                  'All guests assigned!'),
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lang.t(
                                  'പുതിയ അതിഥികളെ ചേർത്ത് വീണ്ടും ശ്രമിക്കുക',
                                  'Add more guests and try again'),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _guestTile(
    BuildContext ctx,
    LanguageProvider lang,
    Guest guest,
    SeatingProvider seating,
    String tableId, {
    bool isAssigned = false,
    bool canAssign = true,
  }) {
    final table = seating.getTableById(tableId);
    final canAdd = canAssign && table != null && !table.isFull;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isAssigned
            ? AppColors.primary.withValues(alpha: 0.06)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isAssigned
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.2))
            : null,
      ),
      child: Row(
        children: [
          Text(guest.groupEmoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guest.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: isAssigned
                        ? AppColors.primary
                        : AppColors.textDark,
                  ),
                ),
                Text(
                  guest.group,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (isAssigned)
            GestureDetector(
              onTap: () {
                seating.unassignGuest(guest.id);
                Navigator.pop(ctx);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  lang.t('നീക്കുക', 'Remove'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else if (canAdd)
            GestureDetector(
              onTap: () {
                seating.assignGuest(tableId, guest.id);
                Navigator.pop(ctx);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  lang.t('ചേർക്കുക', 'Add'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                lang.t('നിറഞ്ഞു', 'Full'),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddTableDialog(
      BuildContext context, LanguageProvider lang, SeatingProvider seating) {
    final nameController = TextEditingController();
    final capacityController = TextEditingController(text: '8');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(lang.t('പുതിയ മേശ', 'Add Table')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: lang.t('മേശയുടെ പേര്', 'Table Name'),
                hintText: lang.t('ഉദാ: കുടുംബ മേശ, സുഹൃത്തുക്കൾ',
                    'e.g. Family, Friends'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: capacityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: lang.t('ശേഷി', 'Capacity'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(lang.t('റദ്ദാക്കുക', 'Cancel')),
          ),
          FilledButton(
            onPressed: () {
              final label = nameController.text.trim();
              final cap = int.tryParse(capacityController.text) ?? 8;
              if (label.isNotEmpty) {
                seating.addTable(label, capacity: cap.clamp(1, 50));
                Navigator.pop(ctx);
              }
            },
            child: Text(lang.t('ചേർക്കുക', 'Add')),
          ),
        ],
      ),
    );
  }

  void _showEditTableDialog(BuildContext context, LanguageProvider lang,
      SeatingProvider seating, SeatingTableModel table) {
    final nameController = TextEditingController(text: table.label);
    final capacityController =
        TextEditingController(text: table.capacity.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(lang.t('മേശ എഡിറ്റ് ചെയ്യുക', 'Edit Table')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: lang.t('മേശയുടെ പേര്', 'Table Name'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: capacityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: lang.t('ശേഷി', 'Capacity'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(lang.t('റദ്ദാക്കുക', 'Cancel')),
          ),
          FilledButton(
            onPressed: () {
              final label = nameController.text.trim();
              final cap = int.tryParse(capacityController.text) ?? 8;
              if (label.isNotEmpty) {
                seating.renameTable(table.id, label);
                final clamped = cap.clamp(1, 50);
                if (clamped != table.capacity) {
                  seating.renameTable(table.id, label);
                }
                Navigator.pop(ctx);
              }
            },
            child: Text(lang.t('സേവ് ചെയ്യുക', 'Save')),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, LanguageProvider lang,
      SeatingProvider seating) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(lang.t('എല്ലാം മായ്ക്കുക', 'Clear All')),
        content: Text(lang.t(
            'എല്ലാ മേശകളും അതിഥി നിയോഗങ്ങളും മായ്ക്കണോ?',
            'Remove all tables and guest assignments?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(lang.t('റദ്ദാക്കുക', 'Cancel')),
          ),
          FilledButton(
            onPressed: () {
              seating.reset();
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent),
            child: Text(lang.t('മായ്ക്കുക', 'Clear')),
          ),
        ],
      ),
    );
  }
}
