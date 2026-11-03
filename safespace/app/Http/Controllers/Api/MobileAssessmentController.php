<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Carbon\Carbon;

class MobileAssessmentController extends Controller
{
    private const MOODS = [
        1 => 'very_bad',
        2 => 'bad',
        3 => 'neutral',
        4 => 'good',
        5 => 'very_good',
    ];

    private const LABELS = [
        1 => 'Very Bad',
        2 => 'Bad',
        3 => 'Neutral',
        4 => 'Good',
        5 => 'Very Good',
    ];

    // ======================================
    // VALIDATE ADMIN CONFIGURED OPTIONS
    // ======================================
    private function scoredOptions($raw): ?array
    {
        $options = is_string($raw)
            ? json_decode($raw, true)
            : $raw;

        if (
            !is_array($options) ||
            !array_is_list($options) ||
            count($options) < 2
        ) {
            return null;
        }

        $result = [];

        foreach ($options as $option) {
            if (!is_array($option)) {
                return null;
            }

            $label = $option['label']
                ?? $option['text']
                ?? null;

            $score = filter_var(
                $option['score'] ?? null,
                FILTER_VALIDATE_INT
            );

            if (
                !is_string($label) ||
                trim($label) === '' ||
                mb_strlen($label) > 255 ||
                $score === false ||
                $score < 1 ||
                $score > 5
            ) {
                return null;
            }

            $result[] = [
                'label' => trim($label),
                'score' => (int) $score,
            ];
        }

        return $result;
    }

    // ======================================
    // LOOK UP A PUBLISHED ASSESSMENT GROUP
    // ======================================
    private function assessmentQuestions(int $id)
    {
        $first = DB::table('admins_questionnaire')
            ->where('id', $id)
            ->where('is_published', 1)
            ->first();

        if (!$first) {
            return null;
        }

        $questions = DB::table('admins_questionnaire')
            ->where('title', $first->title)
            ->where('is_published', 1)
            ->orderBy('id')
            ->get();

        return [
            'title' => $first->title,
            'questions' => $questions,
        ];
    }

    // ======================================
    // GET /api/assessments
    // ======================================
    public function index()
    {
        $questions = DB::table('admins_questionnaire')
            ->where('is_published', 1)
            ->orderBy('id')
            ->get();

        $groups = $questions->groupBy('title');

        $data = [];

        foreach ($groups as $title => $items) {
            $ready = true;

            foreach ($items as $item) {
                if ($this->scoredOptions($item->options) === null) {
                    $ready = false;
                    break;
                }
            }

            $data[] = [
                'id' => (int) $items->first()->id,
                'title' => $title,
                'question_count' => $items->count(),
                'is_ready' => $ready,
            ];
        }

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    // ======================================
    // GET /api/assessments/{id}
    // ======================================
    public function show(int $id)
    {
        $assessment = $this->assessmentQuestions($id);

        if (!$assessment) {
            return response()->json([
                'success' => false,
                'message' => 'Assessment not found.',
            ], 404);
        }

        $questions = [];

        foreach ($assessment['questions'] as $item) {
            $options = $this->scoredOptions($item->options);

            if ($options === null) {
                return response()->json([
                    'success' => false,
                    'message' =>
                        'Assessment options require scoring configuration by Admin.',
                ], 422);
            }

            $visibleOptions = [];

            foreach ($options as $index => $option) {
                $visibleOptions[] = [
                    'index' => $index,
                    'label' => $option['label'],
                ];
            }

            $questions[] = [
                'id' => (int) $item->id,
                'question' => $item->question,
                'options' => $visibleOptions,
            ];
        }

        return response()->json([
            'success' => true,
            'id' => $id,
            'title' => $assessment['title'],
            'questions' => $questions,
        ]);
    }

    // ======================================
    // POST /api/assessments/{id}/submit
    // ======================================
    public function submit(Request $request, int $id)
    {
        $validated = $request->validate([
            'answers' => [
                'required',
                'array',
                'min:1',
                'max:100',
            ],
            'answers.*.question_id' => [
                'required',
                'integer',
            ],
            'answers.*.option_index' => [
                'required',
                'integer',
                'min:0',
            ],
        ]);

        $assessment = $this->assessmentQuestions($id);

        if (!$assessment) {
            return response()->json([
                'success' => false,
                'message' => 'Assessment not found.',
            ], 404);
        }

        $questions = $assessment['questions'];
        $answers = $validated['answers'];

        if (count($answers) !== $questions->count()) {
            throw ValidationException::withMessages([
                'answers' => [
                    'Please answer every question.',
                ],
            ]);
        }

        $answerMap = [];

        foreach ($answers as $answer) {
            $questionId = (int) $answer['question_id'];

            // Prevent duplicate answers for a question
            if (isset($answerMap[$questionId])) {
                throw ValidationException::withMessages([
                    'answers' => [
                        'Duplicate question answer detected.',
                    ],
                ]);
            }

            $answerMap[$questionId] =
                (int) $answer['option_index'];
        }

        $userId = (int) $request->user()->id;
        $rows = [];
        $totalScore = 0;
        $timestamp = now();

        // Validate and score answers server-side
        foreach ($questions as $question) {
            $questionId = (int) $question->id;

            if (!array_key_exists($questionId, $answerMap)) {
                throw ValidationException::withMessages([
                    'answers' => [
                        'One or more answers are missing.',
                    ],
                ]);
            }

            $options = $this->scoredOptions(
                $question->options
            );

            if ($options === null) {
                return response()->json([
                    'success' => false,
                    'message' =>
                        'Assessment scoring is not configured.',
                ], 422);
            }

            $index = $answerMap[$questionId];

            if (!array_key_exists($index, $options)) {
                throw ValidationException::withMessages([
                    'answers' => [
                        'An invalid answer was selected.',
                    ],
                ]);
            }

            $selected = $options[$index];
            $score = $selected['score'];

            $totalScore += $score;

            $rows[] = [
                'questionnaire_id' => $questionId,
                'user_id' => $userId,
                'selected_answer' => $selected['label'],
                'score' => $score,
                'created_at' => $timestamp,
                'updated_at' => $timestamp,
            ];
        }

        $questionCount = $questions->count();

        // Average on the 1-5 scale
        $average = round(
            $totalScore / $questionCount,
            2
        );

        $moodScore = max(
            1,
            min(5, (int) round($average))
        );

        $mood = self::MOODS[$moodScore];

        $today = Carbon::now('Asia/Kuala_Lumpur')
            ->toDateString();

        // Non-diagnostic, general wellness guidance
        $guidance = match ($moodScore) {
            1 => 'Your answers suggest a difficult day. Consider reaching out to someone you trust for support.',
            2 => 'You may be facing some challenges. Consider taking a break and speaking with someone supportive.',
            3 => 'Your answers suggest a mixed day. Continue checking in with your feelings.',
            4 => 'Your answers suggest a generally positive day. Keep making time for activities that support your well-being.',
            5 => 'Your answers suggest a very positive day. Reflect on what helped you feel supported today.',
        };

        // Save both responses and daily mood together
        DB::transaction(function () use (
            $rows,
            $userId,
            $mood,
            $moodScore,
            $today,
            $assessment,
            $timestamp
        ) {
            // Keep questionnaire submission history
            DB::table('admins_questionnaire_reply')
                ->insert($rows);

            // One daily mood record per user
            DB::table('users_mental_health')->upsert(
                [
                    [
                        'user_id' => $userId,
                        'mood' => $mood,
                        'mood_score' => $moodScore,
                        'note' => 'Self-assessment: ' .
                            mb_substr($assessment['title'], 0, 150),
                        'recorded_date' => $today,
                        'created_at' => $timestamp,
                        'updated_at' => $timestamp,
                    ],
                ],
                ['user_id', 'recorded_date'],
                [
                    'mood',
                    'mood_score',
                    'note',
                    'updated_at',
                ]
            );
        });

        return response()->json([
            'success' => true,
            'message' => 'Assessment completed successfully.',
            'result' => [
                'title' => $assessment['title'],
                'total_score' => $totalScore,
                'max_score' => $questionCount * 5,
                'average_score' => $average,
                'mood_score' => $moodScore,
                'mood' => $mood,
                'mood_label' => self::LABELS[$moodScore],
                'recorded_date' => $today,
                'guidance' => $guidance,
            ],
        ], 201);
    }
}
