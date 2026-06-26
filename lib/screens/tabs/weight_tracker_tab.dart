import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/weight_entry.dart';
import '../../providers/fitness_provider.dart';
import '../../widgets/chart_card.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/section_title.dart';
import '../../widgets/stat_card.dart';

class WeightTrackerTab extends StatefulWidget {
  const WeightTrackerTab({super.key});

  static _WeightTrackerTabState? _activeState;

  static void openAddWeightSheet() {
    _activeState?._showFormModal();
  }

  @override
  State<WeightTrackerTab> createState() => _WeightTrackerTabState();
}

class _WeightTrackerTabState extends State<WeightTrackerTab> {
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _range = 'Weekly';

  @override
  void initState() {
    super.initState();
    WeightTrackerTab._activeState = this;
  }

  @override
  void dispose() {
    if (WeightTrackerTab._activeState == this) {
      WeightTrackerTab._activeState = null;
    }
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showFormModal({WeightEntry? entry}) {
    if (entry != null) {
      _weightController.text = entry.weight.toString();
      _notesController.text = entry.notes;
      _selectedDate = entry.date;
    } else {
      _weightController.clear();
      _notesController.clear();
      _selectedDate = DateTime.now();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 20,
                  top: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            entry == null
                                ? 'Log a new weight'
                                : 'Update this entry',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        IconButton(
                            icon:
                                const Icon(Icons.close, color: Colors.white60),
                            onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text('Weight (kg)',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                            fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _weightController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          hintText: 'e.g. 74.5',
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.2)),
                          contentPadding: const EdgeInsets.all(16)),
                    ),
                    const SizedBox(height: 16),
                    const Text('Log date',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                            fontSize: 13)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                      primary: Color(0xFF7C3AED),
                                      onPrimary: Colors.white,
                                      surface: Color(0xFF121212),
                                      onSurface: Colors.white)),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setModalState(() => _selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: const Color(0xFF0D0D0D),
                            borderRadius: BorderRadius.circular(14)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  DateFormat('EEEE, MMMM dd, yyyy')
                                      .format(_selectedDate),
                                  style: const TextStyle(color: Colors.white)),
                              const Icon(Icons.calendar_month_rounded,
                                  color: Color(0xFF7C3AED))
                            ]),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Optional note',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                            fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          hintText: 'Morning weigh-in, post-workout...',
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.2)),
                          contentPadding: const EdgeInsets.all(16)),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          final weightVal =
                              double.tryParse(_weightController.text);
                          if (weightVal == null || weightVal <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Please enter a valid weight')));
                            return;
                          }
                          final fitness = Provider.of<FitnessProvider>(context,
                              listen: false);
                          if (entry == null) {
                            fitness.addWeightEntry(weightVal, _selectedDate,
                                _notesController.text);
                          } else {
                            fitness.updateWeightEntry(entry.id, weightVal,
                                _selectedDate, _notesController.text);
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        child: Text(
                            entry == null ? 'Save entry' : 'Update entry',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showGoalModal() {
    final fitness = Provider.of<FitnessProvider>(context, listen: false);
    _weightController.text = fitness.goalWeight.toString();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Set your goal',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                IconButton(
                    icon: const Icon(Icons.close, color: Colors.white30),
                    onPressed: () => Navigator.pop(context))
              ]),
              const SizedBox(height: 16),
              const Text('Target weight (kg)',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: 'e.g. 70.0',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                    contentPadding: const EdgeInsets.all(16)),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final target = double.tryParse(_weightController.text);
                    if (target == null || target <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please enter a valid target')));
                      return;
                    }
                    fitness.setGoalWeight(target);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  child: const Text('Update goal',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fitness = Provider.of<FitnessProvider>(context);
    final entries = fitness.weightEntries;
    final progress = (fitness.goalProgressPercentage / 100).clamp(0.0, 1.0);
    final remaining = (fitness.currentWeight - fitness.goalWeight).abs();

    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Weight tracker',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      Text('Premium insights, trends, and history',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.5))),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showFormModal(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add log'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.16),
                      blurRadius: 24,
                      offset: const Offset(0, 10))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Goal progress',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.78),
                                fontSize: 12,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        Text('${(progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('${remaining.toStringAsFixed(1)} kg to your goal',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.white)),
                      ],
                    ),
                  ),
                  ProgressRing(
                      value: progress,
                      size: 92,
                      accent: Colors.white,
                      icon: Icons.track_changes_rounded,
                      label: 'Goal'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle(
                title: 'Insights', subtitle: 'Your body trend at a glance'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.18,
              children: [
                StatCard(
                    label: 'Current',
                    value: '${fitness.currentWeight.toStringAsFixed(1)} kg',
                    subtitle: 'Latest log',
                    icon: Icons.monitor_weight_rounded,
                    accent: const Color(0xFF7C3AED)),
                StatCard(
                    label: 'Highest',
                    value: '${fitness.highestWeight.toStringAsFixed(1)} kg',
                    subtitle: 'Peak weight',
                    icon: Icons.trending_up_rounded,
                    accent: const Color(0xFF2563EB)),
                StatCard(
                    label: 'Lowest',
                    value: '${fitness.lowestWeight.toStringAsFixed(1)} kg',
                    subtitle: 'Best reading',
                    icon: Icons.trending_down_rounded,
                    accent: const Color(0xFF10B981)),
                StatCard(
                    label: 'Average',
                    value: '${fitness.averageWeight.toStringAsFixed(1)} kg',
                    subtitle: 'Across logs',
                    icon: Icons.auto_graph_rounded,
                    accent: Colors.orange),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.06))),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Trend',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        const SizedBox(height: 6),
                        Text(fitness.weightTrendLabel,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7C3AED),
                                fontWeight: FontWeight.w700)),
                        Text(
                            '${fitness.averageWeeklyChange.toStringAsFixed(1)} kg/week average',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.55))),
                      ],
                    ),
                  ),
                  IconButton(
                      onPressed: () => _showGoalModal(),
                      icon: const Icon(Icons.edit_note_rounded,
                          color: Color(0xFF2563EB))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('History',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Weekly', label: Text('Weekly')),
                    ButtonSegment(value: 'Monthly', label: Text('Monthly'))
                  ],
                  selected: <String>{_range},
                  onSelectionChanged: (values) =>
                      setState(() => _range = values.first),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ChartCard(
                title: 'Weight trend',
                subtitle: 'Smooth curve over your recent $_range entries',
                spots: _buildChartSpots(entries),
                color: const Color(0xFF7C3AED)),
            const SizedBox(height: 20),
            const SectionTitle(
                title: 'Recent logs',
                subtitle: 'Swipe to delete or tap to edit'),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.06))),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.scale_rounded,
                          size: 42, color: Colors.white24),
                      const SizedBox(height: 10),
                      const Text('No logs yet',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                          'Capture your first weigh-in to unlock your trend view.',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.48)),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final log = entries[index];
                  return Dismissible(
                    key: ValueKey(log.id),
                    background: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(18)),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: Color(0xFFEF4444)),
                    ),
                    onDismissed: (_) async {
                      HapticFeedback.mediumImpact();
                      await fitness.deleteWeightEntry(log.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Weight log removed')));
                      }
                    },
                    child: InkWell(
                      onTap: () => _showFormModal(entry: log),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: const Color(0xFF121212),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.06))),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF7C3AED).withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(16)),
                              child: const Icon(Icons.monitor_weight_rounded,
                                  color: Color(0xFF7C3AED), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${log.weight.toStringAsFixed(1)} kg',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                  Text(
                                      log.notes.isEmpty
                                          ? 'No notes'
                                          : log.notes,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.5)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(DateFormat('MMM dd').format(log.date),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                                const SizedBox(height: 4),
                                const Icon(Icons.chevron_right_rounded,
                                    color: Colors.white38),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _buildChartSpots(List<WeightEntry> entries) {
    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));
    final window = _range == 'Monthly' ? 30 : 7;
    final slice = sorted.length > window
        ? sorted.sublist(sorted.length - window)
        : sorted;
    return [
      for (int i = 0; i < slice.length; i++)
        FlSpot(i.toDouble(), slice[i].weight)
    ];
  }
}
