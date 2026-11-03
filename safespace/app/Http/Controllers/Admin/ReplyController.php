<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\QueryException;

class ReplyController extends Controller
{
    /*
    |--------------------------------------------------------------------------
    | DISPLAY AND SEARCH JOURNAL REPLIES
    |--------------------------------------------------------------------------
    */

    public function index(Request $request)
    {
        // Validate search input
        $validated = $request->validate([
            'search' => 'nullable|string|max:100',
        ]);

        // Get search keyword
        $search = trim($validated['search'] ?? '');

        /*
        |--------------------------------------------------------------------------
        | GET REPLIES AND RELATED JOURNALS
        |--------------------------------------------------------------------------
        */

        $query = DB::table('users_journal_replies as replies')
            ->leftJoin(
                'users_journal as journal',
                'replies.journal_id',
                '=',
                'journal.id'
            )
            ->select(
                'replies.id',
                'replies.journal_id',
                'replies.content',
                'replies.created_at',
                'replies.updated_at',
                'journal.title as journal_title'
            );

        /*
        |--------------------------------------------------------------------------
        | SEARCH REPLY CONTENT OR JOURNAL TITLE
        |--------------------------------------------------------------------------
        */

        if ($search !== '') {

            $query->where(function ($q) use ($search) {

                $q->where(
                    'replies.content',
                    'LIKE',
                    "%{$search}%"
                )
                ->orWhere(
                    'journal.title',
                    'LIKE',
                    "%{$search}%"
                );

            });
        }

        /*
        |--------------------------------------------------------------------------
        | SORT AND PAGINATE
        |--------------------------------------------------------------------------
        */

        $replies = $query
            ->orderBy('replies.created_at', 'desc')
            ->orderBy('replies.id', 'desc')
            ->paginate(10)
            ->withQueryString();

        /*
        |--------------------------------------------------------------------------
        | TOTAL REPLIES
        |--------------------------------------------------------------------------
        */

        $totalReplies = DB::table('users_journal_replies')
            ->count();

        /*
        |--------------------------------------------------------------------------
        | DISPLAY REPLIES LIST
        |--------------------------------------------------------------------------
        */

        return view('admin.replies.index', compact(
            'replies',
            'totalReplies',
            'search'
        ));
    }

    /*
    |--------------------------------------------------------------------------
    | DISPLAY REPLY DETAILS
    |--------------------------------------------------------------------------
    */

    public function show(int $id)
    {
        // Find selected reply
        $reply = DB::table('users_journal_replies')
            ->select(
                'id',
                'journal_id',
                'content',
                'created_at',
                'updated_at'
            )
            ->where('id', $id)
            ->firstOrFail();

        // Find related journal
        $journal = DB::table('users_journal')
            ->select(
                'id',
                'title',
                'moderation_status',
                'created_at'
            )
            ->where('id', $reply->journal_id)
            ->first();

        // Display Reply Details
        return view('admin.replies.show', compact(
            'reply',
            'journal'
        ));
    }

    /*
    |--------------------------------------------------------------------------
    | DELETE JOURNAL REPLY
    |--------------------------------------------------------------------------
    */

    public function destroy(int $id)
    {
        // Make sure the reply exists
        DB::table('users_journal_replies')
            ->where('id', $id)
            ->firstOrFail();

        try {

            // Delete the selected reply only
            $deleted = DB::table('users_journal_replies')
                ->where('id', $id)
                ->delete();

        } catch (QueryException $e) {

            // Record database error in Laravel logs
            report($e);

            // Return to Reply Details
            return redirect()
                ->route('admin.replies.show', ['id' => $id])
                ->with(
                    'error',
                    'Reply could not be deleted. Please check related database records.'
                );
        }

        // Check whether the reply was deleted
        if ($deleted === 0) {

            return redirect()
                ->route('admin.replies.index')
                ->with(
                    'error',
                    'Reply was not deleted. It may already have been removed.'
                );
        }

        // Return to Manage Replies
        return redirect()
            ->route('admin.replies.index')
            ->with(
                'success',
                'Reply deleted successfully.'
            );
    }
}
