import 'package:flutter/material.dart';

import '../models/mood_model.dart';
import '../services/mood_service.dart';
import 'assessment_screen.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  MoodSummary? _summary;
  int _days = 7;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await MoodService.getMoodHistory(days: _days);

      if (!mounted) return;

      setState(() {
        _summary = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _changeDays(int days) {
    if (_loading || _days == days) return;

    _days = days;
    _load();
  }

  Future<void> _openAssessment() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AssessmentScreen()),
    );

    if (mounted) {
      await _load();
    }
  }

  Widget _buildStatistics(MoodSummary summary) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Average Mood',
            summary.averageScore == null
                ? '—'
                : '${summary.averageScore!.toStringAsFixed(1)}/5',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'Days Recorded',
            '${summary.recordCount}/${summary.days}',
          ),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF594780),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(MoodSummary summary) {
    final today = DateTime.parse(summary.todayDate);

    final byDate = {
      for (final entry in summary.entries) entry.recordedDate: entry,
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood Trends',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF594780),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true,
              itemCount: summary.days,
              itemBuilder: (context, reversedIndex) {
                final index = summary.days - reversedIndex - 1;

                final date = today.subtract(
                  Duration(days: summary.days - index - 1),
                );

                final dateKey =
                    '${date.year}-'
                    '${date.month.toString().padLeft(2, '0')}-'
                    '${date.day.toString().padLeft(2, '0')}';

                final score = byDate[dateKey]?.moodScore;

                return SizedBox(
                  width: summary.days == 7 ? 46 : 35,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        score?.toString() ?? '–',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF594780),
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        height: 108,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 19,
                            height: score == null ? 5 : score * 20.0,
                            decoration: BoxDecoration(
                              color: score == null
                                  ? const Color(0xFFE5E1EB)
                                  : const Color(0xFF8E7AB5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${date.day}/${date.month}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mood scores are generated from completed self-assessments. Empty dates have no recorded result.',
            style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory(MoodSummary summary) {
    final entries = summary.entries.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mood History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF594780),
          ),
        ),
        const SizedBox(height: 15),
        if (entries.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No mood records yet.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ...entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(entry.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        entry.displayDate,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      if (entry.note != null && entry.note!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(entry.note!, style: const TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                ),
                Text(
                  '${entry.moodScore}/5',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8E7AB5),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6FC),
        title: const Text(
          'Mood Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF594780),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Your Emotional Journey',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF594780),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Review your moods and reflect on your progress.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _openAssessment,
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Take Self-Assessment'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF8E7AB5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Weekly'),
                    selected: _days == 7,
                    onSelected: (_) => _changeDays(7),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Monthly'),
                    selected: _days == 30,
                    onSelected: (_) => _changeDays(30),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(35),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_error != null)
                Column(
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: _load,
                      child: const Text('Try Again'),
                    ),
                  ],
                )
              else if (_summary != null) ...[
                _buildStatistics(_summary!),
                const SizedBox(height: 18),
                _buildChart(_summary!),
                const SizedBox(height: 28),
                _buildHistory(_summary!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
