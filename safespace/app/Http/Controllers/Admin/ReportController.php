<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    /*
    |--------------------------------------------------------------------------
    | DISPLAY, SEARCH AND FILTER REPORTS
    |--------------------------------------------------------------------------
    */

    public function index(Request $request)
    {
        // Validate search and filter inputs
        $validated = $request->validate([
            'search' => 'nullable|string|max:100',
            'status' => 'nullable|in:all,pending,reviewed,resolved',
            'type'   => 'nullable|in:all,journal,reply',
        ]);

        // Get search keyword
        $search = trim($validated['search'] ?? '');

        // Get selected filters
        $status = $validated['status'] ?? 'all';
        $type = $validated['type'] ?? 'all';

        // Build report query
        $query = DB::table('reports')
            ->select(
                'id',
                'reporter_user_id',
                'target_type',
                'journal_id',
                'reply_id',
                'reason',
                'description',
                'status',
                'created_at'
            );

        /*
        |--------------------------------------------------------------------------
        | SEARCH REPORTS
        |--------------------------------------------------------------------------
        */

        if ($search !== '') {

            $query->where(function ($q) use ($search) {

                $q->where(
                    'reason',
                    'LIKE',
                    "%{$search}%"
                )
                ->orWhere(
                    'description',
                    'LIKE',
                    "%{$search}%"
                );

            });
        }

        /*
        |--------------------------------------------------------------------------
        | FILTER BY REPORT STATUS
        |--------------------------------------------------------------------------
        */

        if (in_array(
            $status,
            ['pending', 'reviewed', 'resolved'],
            true
        )) {

            $query->where('status', $status);

        }

        /*
        |--------------------------------------------------------------------------
        | FILTER BY REPORT TYPE
        |--------------------------------------------------------------------------
        */

        if (in_array(
            $type,
            ['journal', 'reply'],
            true
        )) {

            $query->where('target_type', $type);

        }

        /*
        |--------------------------------------------------------------------------
        | SORT AND PAGINATE
        |--------------------------------------------------------------------------
        */

        $reports = $query
            ->orderBy('created_at', 'desc')
            ->orderBy('id', 'desc')
            ->paginate(10)
            ->withQueryString();

        /*
        |--------------------------------------------------------------------------
        | REPORT STATISTICS
        |--------------------------------------------------------------------------
        */

        // Statistics show all reports,
        // regardless of the selected filters

        $totalReports = DB::table('reports')
            ->count();

        $pendingReports = DB::table('reports')
            ->where('status', 'pending')
            ->count();

        $reviewedReports = DB::table('reports')
            ->where('status', 'reviewed')
            ->count();

        $resolvedReports = DB::table('reports')
            ->where('status', 'resolved')
            ->count();

        /*
        |--------------------------------------------------------------------------
        | DISPLAY MANAGE REPORTS PAGE
        |--------------------------------------------------------------------------
        */

        return view('admin.reports.index', compact(
            'reports',
            'totalReports',
            'pendingReports',
            'reviewedReports',
            'resolvedReports',
            'search',
            'status',
            'type'
        ));
    }

    /*
    |--------------------------------------------------------------------------
    | DISPLAY REPORT DETAILS
    |--------------------------------------------------------------------------
    */

    public function show(int $id)
    {
        // Find the selected report
        $report = DB::table('reports')
            ->select(
                'id',
                'reporter_user_id',
                'target_type',
                'journal_id',
                'reply_id',
                'reason',
                'description',
                'status',
                'admin_notes',
                'reviewed_at',
                'created_at',
                'updated_at'
            )
            ->where('id', $id)
            ->firstOrFail();

        // Default reported content
        $targetJournal = null;
        $targetReply = null;

        /*
        |--------------------------------------------------------------------------
        | REPORTED JOURNAL
        |--------------------------------------------------------------------------
        */

        if (
            $report->target_type === 'journal'
            && $report->journal_id !== null
        ) {

            $targetJournal = DB::table('users_journal')
                ->select(
                    'id',
                    'title',
                    'content',
                    'moderation_status',
                    'created_at'
                )
                ->where('id', $report->journal_id)
                ->first();
        }

        /*
        |--------------------------------------------------------------------------
        | REPORTED REPLY
        |--------------------------------------------------------------------------
        */

        if (
            $report->target_type === 'reply'
            && $report->reply_id !== null
        ) {

            $targetReply = DB::table('users_journal_replies')
                ->select(
                    'id',
                    'journal_id',
                    'content',
                    'created_at'
                )
                ->where('id', $report->reply_id)
                ->first();
        }

        // Display Report Details page
        return view('admin.reports.show', compact(
            'report',
            'targetJournal',
            'targetReply'
        ));
    }

    /*
    |--------------------------------------------------------------------------
    | UPDATE REPORT STATUS AND ADMIN NOTES
    |--------------------------------------------------------------------------
    */

    public function updateStatus(Request $request, int $id)
    {
        // Validate input
        $validated = $request->validate([
            'status' => 'required|in:pending,reviewed,resolved',
            'admin_notes' => 'nullable|string|max:5000',
        ]);

        // Find report
        $report = DB::table('reports')
            ->where('id', $id)
            ->firstOrFail();

        // Get requested status
        $newStatus = $validated['status'];

        // Clean admin notes
        $adminNotes = trim(
            $validated['admin_notes'] ?? ''
        );

        if ($adminNotes === '') {
            $adminNotes = null;
        }

        /*
        |--------------------------------------------------------------------------
        | HANDLE REVIEWED DATE
        |--------------------------------------------------------------------------
        */

        $reviewedAt = $report->reviewed_at;

        if ($newStatus === 'pending') {

            // Reset reviewed date
            $reviewedAt = null;

        } elseif ($reviewedAt === null) {

            // Set first review date
            $reviewedAt = now();

        }

        /*
        |--------------------------------------------------------------------------
        | UPDATE REPORT
        |--------------------------------------------------------------------------
        */

        DB::table('reports')
            ->where('id', $id)
            ->update([
                'status' => $newStatus,
                'admin_notes' => $adminNotes,
                'reviewed_at' => $reviewedAt,
                'updated_at' => now(),
            ]);

        // Success message
        $message = match ($newStatus) {
            'pending' => 'Report status updated to Pending.',
            'reviewed' => 'Report marked as Reviewed successfully.',
            'resolved' => 'Report marked as Resolved successfully.',
        };

        return redirect()
            ->route('admin.reports.show', ['id' => $id])
            ->with('success', $message);
    }
}
