<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    /*
    |--------------------------------------------------------------------------
    | DISPLAY ADMIN DASHBOARD
    |--------------------------------------------------------------------------
    */

    public function index()
    {
        /*
        |--------------------------------------------------------------------------
        | USER STATISTICS
        |--------------------------------------------------------------------------
        */

        // Total registered users
        $totalUsers = DB::table('users')
            ->count();

        // Total active users
        $totalActiveUsers = DB::table('users')
            ->where('account_status', 'active')
            ->count();

        // Total inactive users
        $totalInactiveUsers = DB::table('users')
            ->where('account_status', 'inactive')
            ->count();


        /*
        |--------------------------------------------------------------------------
        | JOURNAL STATISTICS
        |--------------------------------------------------------------------------
        */

        // Total journal posts
        $totalPosts = DB::table('users_journal')
            ->count();

        // Total normal journals
        $totalNormalJournals = DB::table('users_journal')
            ->where('moderation_status', 'normal')
            ->count();

        // Total hidden journals
        $totalHiddenJournals = DB::table('users_journal')
            ->where('moderation_status', 'hidden')
            ->count();


        /*
        |--------------------------------------------------------------------------
        | JOURNAL REPLIES STATISTICS
        |--------------------------------------------------------------------------
        */

        // Total journal replies
        $totalReplies = DB::table('users_journal_replies')
            ->count();


        /*
        |--------------------------------------------------------------------------
        | MOOD STATISTICS
        |--------------------------------------------------------------------------
        */

        // Total valid mood records
        $totalMoodRecords = DB::table('users_mental_health')
            ->whereBetween('mood_score', [1, 5])
            ->count();

        // Calculate average mood score
        $averageMoodScore = DB::table('users_mental_health')
            ->whereBetween('mood_score', [1, 5])
            ->avg('mood_score');

        // Round average score when records exist
        if ($averageMoodScore !== null) {

            $averageMoodScore = round(
                (float) $averageMoodScore,
                2
            );

        }


        /*
        |--------------------------------------------------------------------------
        | REPORT STATISTICS
        |--------------------------------------------------------------------------
        */

        // Total reports
        $totalReports = DB::table('reports')
            ->count();

        // Pending reports
        $pendingReports = DB::table('reports')
            ->where('status', 'pending')
            ->count();

        // Reviewed reports
        $reviewedReports = DB::table('reports')
            ->where('status', 'reviewed')
            ->count();

        // Resolved reports
        $resolvedReports = DB::table('reports')
            ->where('status', 'resolved')
            ->count();


        /*
        |--------------------------------------------------------------------------
        | TIPS AND ARTICLES STATISTICS
        |--------------------------------------------------------------------------
        */

        // Total tips
        $totalTips = DB::table('admins_tips')
            ->where('type', 'tip')
            ->count();

        // Total articles
        $totalArticles = DB::table('admins_tips')
            ->where('type', 'article')
            ->count();

        // Total published content
        $totalPublishedContent = DB::table('admins_tips')
            ->where('is_published', 1)
            ->count();

        // Total draft content
        $totalDraftContent = DB::table('admins_tips')
            ->where('is_published', 0)
            ->count();

        // Total tips and articles combined
        $totalContent = DB::table('admins_tips')
            ->count();


        /*
        |--------------------------------------------------------------------------
        | DISPLAY DASHBOARD VIEW
        |--------------------------------------------------------------------------
        */

        return view('admin.dashboard', compact(

            // User statistics
            'totalUsers',
            'totalActiveUsers',
            'totalInactiveUsers',

            // Journal statistics
            'totalPosts',
            'totalNormalJournals',
            'totalHiddenJournals',

            // Reply statistics
            'totalReplies',

            // Mood statistics
            'totalMoodRecords',
            'averageMoodScore',

            // Report statistics
            'totalReports',
            'pendingReports',
            'reviewedReports',
            'resolvedReports',

            // Tips and Articles statistics
            'totalTips',
            'totalArticles',
            'totalPublishedContent',
            'totalDraftContent',
            'totalContent'

        ));
    }
}
