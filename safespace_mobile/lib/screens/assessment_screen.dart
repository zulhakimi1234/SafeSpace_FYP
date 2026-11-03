import 'package:flutter/material.dart';

import '../models/assessment_model.dart';
import '../services/assessment_service.dart';

// ==========================================
// ASSESSMENT LIST
// ==========================================
class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  late Future<List<AssessmentInfo>> _future;

  @override
  void initState() {
    super.initState();
    _future = AssessmentService.getAssessments();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = AssessmentService.getAssessments();
    });

    try {
      await _future;
    } catch (_) {
      // The FutureBuilder displays the error.
    }
  }

  Future<void> _openAssessment(AssessmentInfo assessment) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AssessmentQuestionScreen(assessmentId: assessment.id),
      ),
    );

    if (mounted) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6FC),
        title: const Text(
          'Self-Assessment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF594780),
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<AssessmentInfo>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${snapshot.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 15),
                      FilledButton(
                        onPressed: _refresh,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final assessments = snapshot.data ?? [];

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Check In With Yourself',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF594780),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Answer a few questions to reflect on your emotional well-being.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (assessments.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.quiz_outlined,
                            size: 50,
                            color: Color(0xFF8E7AB5),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'No assessments available yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Published assessments will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ...assessments.map((assessment) {
                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.assignment_outlined,
                              size: 35,
                              color: Color(0xFF8E7AB5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              assessment.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${assessment.questionCount} questions',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 14),
                            if (!assessment.isReady)
                              const Text(
                                'Scoring configuration is incomplete. Ask Admin to configure the question options.',
                                style: TextStyle(
                                  color: Colors.deepOrange,
                                  fontSize: 12,
                                ),
                              ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: assessment.isReady
                                    ? () => _openAssessment(assessment)
                                    : null,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF8E7AB5),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                child: Text(
                                  assessment.isReady
                                      ? 'Start Assessment'
                                      : 'Not Ready',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  const Text(
                    'Assessments provide general self-reflection and do not replace professional mental health advice.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ==========================================
// ASSESSMENT QUESTIONS
// ==========================================
class AssessmentQuestionScreen extends StatefulWidget {
  final int assessmentId;

  const AssessmentQuestionScreen({super.key, required this.assessmentId});

  @override
  State<AssessmentQuestionScreen> createState() =>
      _AssessmentQuestionScreenState();
}

class _AssessmentQuestionScreenState extends State<AssessmentQuestionScreen> {
  late Future<AssessmentDetail> _future;

  final Map<int, int> _answers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _future = AssessmentService.getAssessment(widget.assessmentId);
  }

  Future<void> _submit(AssessmentDetail assessment) async {
    if (_isSubmitting) return;

    if (_answers.length != assessment.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before submitting.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await AssessmentService.submitAnswers(
        assessmentId: widget.assessmentId,
        answers: _answers,
      );

      if (!mounted) return;

      final completed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => AssessmentResultScreen(result: result),
        ),
      );

      if (!mounted) return;

      if (completed == true) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildQuestion(AssessmentQuestion question, int number) {
    final selectedIndex = _answers[question.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question $number',
            style: const TextStyle(
              color: Color(0xFF8E7AB5),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.question,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ...question.options.map((option) {
            final isSelected = selectedIndex == option.index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Material(
                color: isSelected
                    ? const Color(0xFFE8DFF5)
                    : const Color(0xFFF8F6FC),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _answers[question.id] = option.index;
                          });
                        },
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: const Color(0xFF8E7AB5),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option.label,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: const Color(0xFF333333),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6FC),
        title: const Text(
          'Answer Assessment',
          style: TextStyle(
            color: Color(0xFF594780),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<AssessmentDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Text(
                  '${snapshot.error ?? 'Assessment unavailable.'}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final assessment = snapshot.data!;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  assessment.title,
                  style: const TextStyle(
                    color: Color(0xFF594780),
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${_answers.length} of ${assessment.questions.length} questions answered',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ...List.generate(
                  assessment.questions.length,
                  (index) =>
                      _buildQuestion(assessment.questions[index], index + 1),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: _isSubmitting ? null : () => _submit(assessment),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8E7AB5),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(55),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Assessment',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// ASSESSMENT RESULT
// ==========================================
class AssessmentResultScreen extends StatelessWidget {
  final AssessmentResult result;

  const AssessmentResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF8F6FC),
        title: const Text(
          'Assessment Result',
          style: TextStyle(
            color: Color(0xFF594780),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF70B69B),
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Assessment Completed!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF594780),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        Text(
                          result.emoji,
                          style: const TextStyle(fontSize: 65),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          result.moodLabel,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF594780),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Mood Score: ${result.moodScore}/5',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Total Score: ${result.totalScore}/${result.maxScore}',
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Average Score: ${result.averageScore.toStringAsFixed(2)}/5',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8DFF5),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Wellness Guidance',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF594780),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          result.guidance,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF594780),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'This result is for personal reflection only and is not a medical diagnosis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8E7AB5),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(55),
                      ),
                      child: const Text('Return to Assessments'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
