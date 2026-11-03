<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class MobileWellnessController extends Controller
{
    // ==========================================
    // GET /api/wellness
    // Published resources only
    // ==========================================
    public function index(Request $request)
    {
        $validated = $request->validate([
            'type' => [
                'nullable',
                Rule::in(['article', 'tip']),
            ],
            'search' => [
                'nullable',
                'string',
                'max:100',
            ],
            'page' => [
                'sometimes',
                'integer',
                'min:1',
            ],
        ]);

        $query = DB::table('admins_tips')
            ->where('is_published', 1);

        // Optional type filter
        if (!empty($validated['type'])) {
            $query->where(
                'type',
                $validated['type']
            );
        }

        // Optional search
        $search = trim($validated['search'] ?? '');

        if ($search !== '') {
            $query->where(function ($q) use ($search) {
                $q->where(
                    'title',
                    'like',
                    '%' . $search . '%'
                )->orWhere(
                    'content',
                    'like',
                    '%' . $search . '%'
                )->orWhere(
                    'category',
                    'like',
                    '%' . $search . '%'
                );
            });
        }

        // 10 resources per page
        $resources = $query
            ->select([
                'id',
                'title',
                'content',
                'category',
                'type',
                'updated_at',
            ])
            ->orderByDesc('updated_at')
            ->orderByDesc('id')
            ->paginate(10);

        $data = [];

        foreach ($resources->items() as $item) {
            $preview = trim(
                strip_tags((string) $item->content)
            );

            $data[] = [
                'id' => (int) $item->id,
                'title' => $item->title,
                'category' => $item->category,
                'type' => $item->type,
                'preview' => Str::limit(
                    $preview,
                    180
                ),
                'updated_at' => $item->updated_at,
            ];
        }

        return response()->json([
            'success' => true,
            'data' => $data,
            'current_page' =>
                $resources->currentPage(),
            'has_more' =>
                $resources->hasMorePages(),
            'total' => $resources->total(),
        ]);
    }

    // ==========================================
    // GET /api/wellness/{id}
    // View single published resource
    // ==========================================
    public function show(int $id)
    {
        $resource = DB::table('admins_tips')
            ->where('id', $id)
            ->where('is_published', 1)
            ->first([
                'id',
                'title',
                'content',
                'category',
                'type',
                'updated_at',
            ]);

        if (!$resource) {
            return response()->json([
                'success' => false,
                'message' =>
                    'Wellness resource not found.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => (int) $resource->id,
                'title' => $resource->title,
                'content' => $resource->content,
                'category' => $resource->category,
                'type' => $resource->type,
                'updated_at' => $resource->updated_at,
            ],
        ]);
    }
}
