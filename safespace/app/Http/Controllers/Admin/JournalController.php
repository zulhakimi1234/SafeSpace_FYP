<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\QueryException;

class JournalController extends Controller
{
    // Display, search and filter journal posts
    public function index(Request $request)
    {
        // Validate search and moderation status
        $validated = $request->validate([
            'search' => 'nullable|string|max:100',
            'status' => 'nullable|in:all,normal,hidden',
        ]);

        // Get search keyword
        $search = trim($validated['search'] ?? '');

        // Get selected moderation status
        $status = $validated['status'] ?? 'all';

        // Get journals from database
        $query = DB::table('users_journal')
            ->select(
                'id',
                'title',
                'content',
                'moderation_status',
                'created_at'
            );

        // Search journal title or content
        if ($search !== '') {

            $query->where(function ($q) use ($search) {

                $q->where(
                    'title',
                    'LIKE',
                    "%{$search}%"
                )
                ->orWhere(
                    'content',
                    'LIKE',
                    "%{$search}%"
                );

            });
        }

        // Filter by moderation status
        if ($status === 'normal' || $status === 'hidden') {

            $query->where(
                'moderation_status',
                $status
            );

        }

        // Sort newest first and paginate
        $journals = $query
            ->orderBy('created_at', 'desc')
            ->orderBy('id', 'desc')
            ->paginate(10)
            ->withQueryString();

        // Display Manage Journals page
        return view('admin.journals.index', compact(
            'journals',
            'search',
            'status'
        ));
    }

    // Display a specific journal's details
    public function show(int $id)
    {
        $journal = DB::table('users_journal')
            ->select(
                'id',
                'title',
                'content',
                'moderation_status',
                'created_at',
                'updated_at'
            )
            ->where('id', $id)
            ->firstOrFail();

        return view('admin.journals.show', compact(
            'journal'
        ));
    }

    // Hide or unhide journal
    public function updateModerationStatus(
        Request $request,
        int $id
    ) {
        // Validate requested moderation status
        $validated = $request->validate([
            'moderation_status' => 'required|in:normal,hidden',
        ]);

        // Find journal
        $journal = DB::table('users_journal')
            ->where('id', $id)
            ->firstOrFail();

        // Get requested status
        $newStatus = $validated['moderation_status'];

        // Avoid unnecessary updates
        if ($journal->moderation_status === $newStatus) {

            return redirect()
                ->route('admin.journals.show', ['id' => $id])
                ->with(
                    'success',
                    'Journal already has the selected moderation status.'
                );
        }

        // Update moderation status
        DB::table('users_journal')
            ->where('id', $id)
            ->update([
                'moderation_status' => $newStatus,
            ]);

        // Prepare success message
        $message = $newStatus === 'hidden'
            ? 'Journal hidden successfully.'
            : 'Journal unhidden successfully.';

        // Return to Journal Details
        return redirect()
            ->route('admin.journals.show', ['id' => $id])
            ->with('success', $message);
    }

    // Permanently delete a journal
    public function destroy(int $id)
    {
        // Make sure journal exists
        DB::table('users_journal')
            ->where('id', $id)
            ->firstOrFail();

        try {

            // Delete selected journal
            $deleted = DB::table('users_journal')
                ->where('id', $id)
                ->delete();

        } catch (QueryException $e) {

            // Log database error
            report($e);

            return redirect()
                ->route('admin.journals.show', ['id' => $id])
                ->with(
                    'error',
                    'Journal could not be deleted. Please check related records.'
                );
        }

        // Check deletion result
        if ($deleted === 0) {

            return redirect()
                ->route('admin.journals.index')
                ->with(
                    'error',
                    'Journal was not deleted. It may already have been removed.'
                );
        }

        // Return to Manage Journals
        return redirect()
            ->route('admin.journals.index')
            ->with(
                'success',
                'Journal deleted successfully.'
            );
    }
}
