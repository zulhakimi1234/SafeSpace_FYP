<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class MobileTaskController extends Controller
{
    private const STATUSES = [
        'pending',
        'in_progress',
        'completed',
    ];

    // Format task data for the Flutter app
    private function formatTask($task): array
    {
        return [
            'id' => (int) $task->id,
            'title' => $task->title,
            'description' => $task->description,
            'category' => $task->category,
            'due_date' => $task->due_date,
            'status' => $task->status,
            'created_at' => $task->created_at,
            'updated_at' => $task->updated_at,
        ];
    }

    // GET /api/tasks
    // Retrieve authenticated user's tasks only
    public function index(Request $request)
    {
        $userId = (int) $request->user()->id;

        $tasks = DB::table('users_task')
            ->where('user_id', $userId)
            ->orderByRaw(
                'CASE WHEN due_date IS NULL THEN 1 ELSE 0 END'
            )
            ->orderBy('due_date', 'asc')
            ->orderByDesc('id')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $tasks->map(
                fn ($task) => $this->formatTask($task)
            )->values(),
        ]);
    }

    // POST /api/tasks
    // Create a new task
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => [
                'required',
                'string',
                'max:150',
            ],
            'description' => [
                'nullable',
                'string',
                'max:5000',
            ],
            'category' => [
                'nullable',
                'string',
                'max:50',
            ],
            'due_date' => [
                'nullable',
                'date_format:Y-m-d',
            ],
            'status' => [
                'required',
                Rule::in(self::STATUSES),
            ],
        ]);

        $title = trim($validated['title']);

        if ($title === '') {
            return response()->json([
                'success' => false,
                'message' => 'Task title cannot be empty.',
            ], 422);
        }

        $timestamp = now();

        $id = DB::table('users_task')->insertGetId([
            'user_id' => $request->user()->id,
            'title' => $title,
            'description' => $validated['description'] ?? null,
            'category' => $validated['category'] ?? null,
            'due_date' => $validated['due_date'] ?? null,
            'status' => $validated['status'],
            'created_at' => $timestamp,
            'updated_at' => $timestamp,
        ]);

        $task = DB::table('users_task')
            ->where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        return response()->json([
            'success' => true,
            'message' => 'Task created successfully.',
            'data' => $this->formatTask($task),
        ], 201);
    }

    // GET /api/tasks/{id}
    // Get only task owned by current user
    public function show(Request $request, int $id)
    {
        $task = DB::table('users_task')
            ->where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$task) {
            return response()->json([
                'success' => false,
                'message' => 'Task not found.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $this->formatTask($task),
        ]);
    }

    // PUT /api/tasks/{id}
    // Update only own task
    public function update(Request $request, int $id)
    {
        $validated = $request->validate([
            'title' => [
                'required',
                'string',
                'max:150',
            ],
            'description' => [
                'nullable',
                'string',
                'max:5000',
            ],
            'category' => [
                'nullable',
                'string',
                'max:50',
            ],
            'due_date' => [
                'nullable',
                'date_format:Y-m-d',
            ],
            'status' => [
                'required',
                Rule::in(self::STATUSES),
            ],
        ]);

        $title = trim($validated['title']);

        if ($title === '') {
            return response()->json([
                'success' => false,
                'message' => 'Task title cannot be empty.',
            ], 422);
        }

        $userId = (int) $request->user()->id;

        $taskQuery = DB::table('users_task')
            ->where('id', $id)
            ->where('user_id', $userId);

        if (!(clone $taskQuery)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Task not found.',
            ], 404);
        }

        $taskQuery->update([
            'title' => $title,
            'description' => $validated['description'] ?? null,
            'category' => $validated['category'] ?? null,
            'due_date' => $validated['due_date'] ?? null,
            'status' => $validated['status'],
            'updated_at' => now(),
        ]);

        $task = DB::table('users_task')
            ->where('id', $id)
            ->where('user_id', $userId)
            ->first();

        return response()->json([
            'success' => true,
            'message' => 'Task updated successfully.',
            'data' => $this->formatTask($task),
        ]);
    }

    // DELETE /api/tasks/{id}
    // Delete only own task
    public function destroy(Request $request, int $id)
    {
        $deleted = DB::table('users_task')
            ->where('id', $id)
            ->where('user_id', $request->user()->id)
            ->delete();

        if ($deleted === 0) {
            return response()->json([
                'success' => false,
                'message' => 'Task not found.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Task deleted successfully.',
        ]);
    }
}
