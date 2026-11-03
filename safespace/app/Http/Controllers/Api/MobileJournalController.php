<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;

class MobileJournalController extends Controller
{
    // Check whether a journal is publicly visible
    private function visibleJournals()
    {
        return DB::table('users_journal')
            ->where(function ($query) {
                $query->where('moderation_status', 'normal')
                    ->orWhereNull('moderation_status');
            });
    }

    // Convert database post into anonymous API response
    private function formatPost($post, int $userId): array
    {
        return [
            'id' => (int) $post->id,
            'title' => $post->title,
            'content' => $post->content,
            'created_at' => Carbon::parse(
                $post->created_at
            )->toIso8601String(),
            'reply_count' => (int) (
                $post->reply_count ?? 0
            ),
            'is_mine' => (int) $post->user_id === $userId,
            'author' => 'Anonymous',
        ];
    }

    // GET /api/journals
    // Display anonymous community feed
    public function index(Request $request)
    {
        $userId = (int) $request->user()->id;

        $journals = $this->visibleJournals()
            ->select(
                'users_journal.id',
                'users_journal.user_id',
                'users_journal.title',
                'users_journal.content',
                'users_journal.created_at'
            )
            ->selectSub(function ($query) {
                $query->from('users_journal_replies')
                    ->selectRaw('COUNT(*)')
                    ->whereColumn(
                        'users_journal_replies.journal_id',
                        'users_journal.id'
                    );
            }, 'reply_count')
            ->orderByDesc('users_journal.created_at')
            ->orderByDesc('users_journal.id')
            ->paginate(10);

        $data = [];

        foreach ($journals->items() as $journal) {
            $data[] = $this->formatPost(
                $journal,
                $userId
            );
        }

        return response()->json([
            'success' => true,
            'data' => $data,
            'current_page' => $journals->currentPage(),
            'has_more' => $journals->hasMorePages(),
        ]);
    }

    // POST /api/journals
    // Create anonymous journal
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => [
                'required',
                'string',
                'max:150',
            ],
            'content' => [
                'required',
                'string',
                'max:5000',
            ],
        ]);

        $title = trim($validated['title']);
        $content = trim($validated['content']);

        $validator = Validator::make(
            [
                'title' => $title,
                'content' => $content,
            ],
            [
                'title' => 'required|string|max:150',
                'content' => 'required|string|max:5000',
            ]
        );

        $validator->validate();

        $id = DB::table('users_journal')->insertGetId([
            'user_id' => $request->user()->id,
            'title' => $title,
            'content' => $content,
            'moderation_status' => 'normal',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Journal published successfully.',
            'journal_id' => $id,
        ], 201);
    }

    // GET /api/journals/{id}
    // Display journal and anonymous replies
    public function show(Request $request, int $id)
    {
        $journal = $this->visibleJournals()
            ->where('id', $id)
            ->first();

        if (!$journal) {
            return response()->json([
                'success' => false,
                'message' => 'Journal not found.',
            ], 404);
        }

        $replies = DB::table('users_journal_replies')
            ->where('journal_id', $id)
            ->orderBy('created_at')
            ->orderBy('id')
            ->get();

        $formattedReplies = [];

        foreach ($replies as $reply) {
            $formattedReplies[] = [
                'id' => (int) $reply->id,
                'content' => $reply->content,
                'created_at' => Carbon::parse(
                    $reply->created_at
                )->toIso8601String(),
                'author' => 'Anonymous',
                'is_mine' =>
                    (int) $reply->user_id ===
                    (int) $request->user()->id,
            ];
        }

        $journal->reply_count = count($formattedReplies);

        return response()->json([
            'success' => true,
            'post' => $this->formatPost(
                $journal,
                (int) $request->user()->id
            ),
            'replies' => $formattedReplies,
        ]);
    }

    // POST /api/journals/{id}/replies
    // Reply anonymously to a journal
    public function reply(Request $request, int $id)
    {
        $validated = $request->validate([
            'content' => [
                'required',
                'string',
                'max:2000',
            ],
        ]);

        $content = trim($validated['content']);

        if ($content === '') {
            return response()->json([
                'success' => false,
                'message' => 'Reply cannot be empty.',
            ], 422);
        }

        $journal = $this->visibleJournals()
            ->where('id', $id)
            ->first();

        if (!$journal) {
            return response()->json([
                'success' => false,
                'message' => 'Journal not found.',
            ], 404);
        }

        $replyId = DB::table(
            'users_journal_replies'
        )->insertGetId([
            'journal_id' => $id,
            'user_id' => $request->user()->id,
            'content' => $content,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Reply posted successfully.',
            'reply_id' => $replyId,
        ], 201);
    }

    // DELETE /api/journals/{id}
    // Delete ONLY the owner's journal
    public function destroy(Request $request, int $id)
    {
        $journal = DB::table('users_journal')
            ->where('id', $id)
            ->first();

        if (!$journal) {
            return response()->json([
                'success' => false,
                'message' => 'Journal not found.',
            ], 404);
        }

        // Ownership verification
        if (
            (int) $journal->user_id !==
            (int) $request->user()->id
        ) {
            return response()->json([
                'success' => false,
                'message' =>
                    'You can only delete your own journal.',
            ], 403);
        }

        // Delete replies and journal together
        DB::transaction(function () use ($id) {
            DB::table('users_journal_replies')
                ->where('journal_id', $id)
                ->delete();

            DB::table('users_journal')
                ->where('id', $id)
                ->delete();
        });

        return response()->json([
            'success' => true,
            'message' => 'Journal deleted successfully.',
        ]);
    }
}
