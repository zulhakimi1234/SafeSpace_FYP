<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class MobileMoodController extends Controller
{
    // Mood labels matching database ENUM
    private const MOODS = [
        1 => 'very_bad',
        2 => 'bad',
        3 => 'neutral',
        4 => 'good',
        5 => 'very_good',
    ];

    // Use Malaysia local date for this FYP prototype
    private function today(): string
    {
        return Carbon::now('Asia/Kuala_Lumpur')
            ->toDateString();
    }

    // Format a private mood entry for mobile
    private function formatEntry($entry): array
    {
        return [
            'id' => (int) $entry->id,
            'mood' => $entry->mood,
            'mood_score' => (int) $entry->mood_score,
            'note' => $entry->note,
            'recorded_date' => $entry->recorded_date,
        ];
    }

    // ======================================
    // GET /api/moods?days=7 OR days=30
    // ======================================
    public function index(Request $request)
    {
        $validated = $request->validate([
            'days' => [
                'sometimes',
                'integer',
                Rule::in([7, 30]),
            ],
        ]);

        $days = (int) ($validated['days'] ?? 7);

        $userId = (int) $request->user()->id;

        $today = Carbon::parse(
            $this->today(),
            'Asia/Kuala_Lumpur'
        );

        $startDate = $today->copy()
            ->subDays($days - 1)
            ->toDateString();

        $todayDate = $today->toDateString();

        // Only the authenticated user's records
        $entries = DB::table('users_mental_health')
            ->where('user_id', $userId)
            ->whereBetween(
                'recorded_date',
                [$startDate, $todayDate]
            )
            ->orderBy('recorded_date', 'asc')
            ->get();

        // Get today's existing mood
        $todayEntry = DB::table('users_mental_health')
            ->where('user_id', $userId)
            ->where('recorded_date', $todayDate)
            ->first();

        $formattedEntries = $entries
            ->map(fn ($entry) =>
                $this->formatEntry($entry)
            )
            ->values();

        $average = $entries->isEmpty()
            ? null
            : round(
                (float) $entries->avg('mood_score'),
                2
            );

        return response()->json([
            'success' => true,
            'days' => $days,
            'today_date' => $todayDate,
            'record_count' => $entries->count(),
            'average_score' => $average,
            'today' => $todayEntry
                ? $this->formatEntry($todayEntry)
                : null,
            'entries' => $formattedEntries,
        ]);
    }

    // ======================================
    // POST /api/moods
    // CREATE OR UPDATE TODAY'S MOOD
    // ======================================
    public function store(Request $request)
    {
        $validated = $request->validate([
            'mood_score' => [
                'required',
                'integer',
                'between:1,5',
            ],
            'note' => [
                'nullable',
                'string',
                'max:1000',
            ],
        ]);

        $userId = (int) $request->user()->id;

        $score = (int) $validated['mood_score'];

        // Prevent mismatched score and mood labels
        $mood = self::MOODS[$score];

        $note = isset($validated['note'])
            ? trim($validated['note'])
            : null;

        if ($note === '') {
            $note = null;
        }

        $todayDate = $this->today();
        $timestamp = now();

        // Insert once per day; update if one exists
        DB::table('users_mental_health')->upsert(
            [
                [
                    'user_id' => $userId,
                    'mood' => $mood,
                    'mood_score' => $score,
                    'note' => $note,
                    'recorded_date' => $todayDate,
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

        $entry = DB::table('users_mental_health')
            ->where('user_id', $userId)
            ->where('recorded_date', $todayDate)
            ->first();

        return response()->json([
            'success' => true,
            'message' => 'Mood saved successfully.',
            'data' => $this->formatEntry($entry),
        ]);
    }
}
