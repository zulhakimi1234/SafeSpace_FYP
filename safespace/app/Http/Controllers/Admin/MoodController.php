<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class MoodController extends Controller
{
    public function index()
    {
        // Count mood records grouped by score
        $moodCounts = DB::table('users_mental_health')
            ->select('mood_score')
            ->selectRaw('COUNT(*) as total')
            ->whereBetween('mood_score', [1, 5])
            ->groupBy('mood_score')
            ->pluck('total', 'mood_score');

        // Prepare all five mood scores
        $distribution = collect(range(1, 5))
            ->map(function ($score) use ($moodCounts) {
                return [
                    'score' => $score,
                    'count' => (int) ($moodCounts[$score] ?? 0),
                ];
            });

        // Calculate total valid mood records
        $totalMoodRecords = $distribution->sum('count');

        // Calculate weighted average mood score
        $averageMoodScore = null;

        if ($totalMoodRecords > 0) {

            $totalScore = $distribution->sum(
                function ($item) {
                    return $item['score'] * $item['count'];
                }
            );

            $averageMoodScore = round(
                $totalScore / $totalMoodRecords,
                2
            );
        }

        // Display Mood Records page
        return view('admin.moods.index', compact(
            'distribution',
            'totalMoodRecords',
            'averageMoodScore'
        ));
    }
}
