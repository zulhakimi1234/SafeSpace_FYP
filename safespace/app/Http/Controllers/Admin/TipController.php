<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\QueryException;

class TipController extends Controller
{
    /*
    |--------------------------------------------------------------------------
    | DISPLAY, SEARCH AND FILTER TIPS & ARTICLES
    |--------------------------------------------------------------------------
    */

    public function index(Request $request)
    {
        /*
        |--------------------------------------------------------------------------
        | VALIDATE SEARCH AND FILTER INPUT
        |--------------------------------------------------------------------------
        */

        $validated = $request->validate([
            'search' => 'nullable|string|max:100',
            'type' => 'nullable|in:tip,article',
            'status' => 'nullable|in:0,1',
        ]);

        // Get search keyword
        $search = trim($validated['search'] ?? '');

        // Get selected type and status
        $type = $validated['type'] ?? '';
        $status = (string) ($validated['status'] ?? '');

        /*
        |--------------------------------------------------------------------------
        | GET TIPS AND ARTICLES WITH ADMIN NAME
        |--------------------------------------------------------------------------
        */

        $query = DB::table('admins_tips as tips')
            ->leftJoin(
                'admins',
                'tips.admin_id',
                '=',
                'admins.id'
            )
            ->select(
                'tips.id',
                'tips.title',
                'tips.content',
                'tips.category',
                'tips.type',
                'tips.is_published',
                'tips.created_at',
                'tips.updated_at',
                'admins.name as admin_name'
            );

        /*
        |--------------------------------------------------------------------------
        | SEARCH BY TITLE OR CATEGORY
        |--------------------------------------------------------------------------
        */

        if ($search !== '') {

            $query->where(function ($q) use ($search) {

                $q->where(
                    'tips.title',
                    'LIKE',
                    "%{$search}%"
                )
                ->orWhere(
                    'tips.category',
                    'LIKE',
                    "%{$search}%"
                );

            });
        }

        /*
        |--------------------------------------------------------------------------
        | FILTER BY CONTENT TYPE
        |--------------------------------------------------------------------------
        */

        if ($type !== '') {

            $query->where('tips.type', $type);

        }

        /*
        |--------------------------------------------------------------------------
        | FILTER BY PUBLICATION STATUS
        |--------------------------------------------------------------------------
        */

        // Important: '0' means Draft
        // Do not use empty($status) here.

        if ($status !== '') {

            $query->where(
                'tips.is_published',
                (int) $status
            );

        }

        /*
        |--------------------------------------------------------------------------
        | SORT AND PAGINATE CONTENT
        |--------------------------------------------------------------------------
        */

        $contents = $query
            ->orderBy('tips.created_at', 'desc')
            ->orderBy('tips.id', 'desc')
            ->paginate(10)
            ->withQueryString();

        /*
        |--------------------------------------------------------------------------
        | OVERALL CONTENT STATISTICS
        |--------------------------------------------------------------------------
        */

        // Count all content
        $totalContents = DB::table('admins_tips')
            ->count();

        // Count published content
        $publishedContents = DB::table('admins_tips')
            ->where('is_published', 1)
            ->count();

        // Count draft content
        $draftContents = DB::table('admins_tips')
            ->where('is_published', 0)
            ->count();

        /*
        |--------------------------------------------------------------------------
        | DISPLAY MANAGE TIPS & ARTICLES PAGE
        |--------------------------------------------------------------------------
        */

        return view('admin.tips.index', compact(
            'contents',
            'totalContents',
            'publishedContents',
            'draftContents',
            'search',
            'type',
            'status'
        ));
    }

    /*
    |--------------------------------------------------------------------------
    | DISPLAY CREATE CONTENT FORM
    |--------------------------------------------------------------------------
    */

    public function create()
    {
        return view('admin.tips.create');
    }

    /*
    |--------------------------------------------------------------------------
    | STORE NEW TIP OR ARTICLE
    |--------------------------------------------------------------------------
    */

    public function store(Request $request)
    {
        // Validate submitted content
        $validated = $request->validate([
            'title' => 'required|string|max:200',
            'content' => 'required|string|max:20000',
            'category' => 'required|string|max:100',
            'type' => 'required|in:tip,article',
            'is_published' => 'required|in:0,1',
        ]);

        // Get currently logged-in admin
        $adminId = Auth::guard('admin')->id();

        // Clean text input
        $title = trim($validated['title']);
        $content = trim($validated['content']);
        $category = trim($validated['category']);

        // Prevent whitespace-only values
        if (
            $title === '' ||
            $content === '' ||
            $category === ''
        ) {
            return back()
                ->withInput()
                ->withErrors([
                    'content' => 'Title, category and content cannot be empty.',
                ]);
        }

        // Save new content
        DB::table('admins_tips')->insert([
            'admin_id' => $adminId,
            'title' => $title,
            'content' => $content,
            'category' => $category,
            'type' => $validated['type'],
            'is_published' => (int) $validated['is_published'],
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Prepare success message
        $message = (int) $validated['is_published'] === 1
            ? 'Content created and published successfully.'
            : 'Content saved as draft successfully.';

        return redirect()
            ->route('admin.tips.index')
            ->with('success', $message);
    }

    /*
    |--------------------------------------------------------------------------
    | DISPLAY CONTENT DETAILS
    |--------------------------------------------------------------------------
    */

    public function show(int $id)
    {
        // Get selected content with creator name
        $content = DB::table('admins_tips as tips')
            ->leftJoin(
                'admins',
                'tips.admin_id',
                '=',
                'admins.id'
            )
            ->select(
                'tips.id',
                'tips.title',
                'tips.content',
                'tips.category',
                'tips.type',
                'tips.is_published',
                'tips.created_at',
                'tips.updated_at',
                'admins.name as admin_name'
            )
            ->where('tips.id', $id)
            ->firstOrFail();

        return view('admin.tips.show', compact(
            'content'
        ));
    }

    /*
    |--------------------------------------------------------------------------
    | DISPLAY EDIT CONTENT FORM
    |--------------------------------------------------------------------------
    */

    public function edit(int $id)
    {
        // Find selected content
        $content = DB::table('admins_tips')
            ->select(
                'id',
                'title',
                'content',
                'category',
                'type',
                'is_published'
            )
            ->where('id', $id)
            ->firstOrFail();

        return view('admin.tips.edit', compact(
            'content'
        ));
    }

    /*
    |--------------------------------------------------------------------------
    | UPDATE EXISTING TIP OR ARTICLE
    |--------------------------------------------------------------------------
    */

    public function update(Request $request, int $id)
    {
        // Validate submitted information
        $validated = $request->validate([
            'title' => 'required|string|max:200',
            'content' => 'required|string|max:20000',
            'category' => 'required|string|max:100',
            'type' => 'required|in:tip,article',
            'is_published' => 'required|in:0,1',
        ]);

        // Make sure content exists
        DB::table('admins_tips')
            ->where('id', $id)
            ->firstOrFail();

        // Clean text input
        $title = trim($validated['title']);
        $content = trim($validated['content']);
        $category = trim($validated['category']);

        // Prevent whitespace-only values
        if (
            $title === '' ||
            $content === '' ||
            $category === ''
        ) {
            return back()
                ->withInput()
                ->withErrors([
                    'content' => 'Title, category and content cannot be empty.',
                ]);
        }

        // Update selected content
        DB::table('admins_tips')
            ->where('id', $id)
            ->update([
                'title' => $title,
                'content' => $content,
                'category' => $category,
                'type' => $validated['type'],
                'is_published' => (int) $validated['is_published'],
                'updated_at' => now(),
            ]);

        return redirect()
            ->route('admin.tips.show', ['id' => $id])
            ->with(
                'success',
                'Content updated successfully.'
            );
    }

    /*
    |--------------------------------------------------------------------------
    | DELETE TIP OR ARTICLE
    |--------------------------------------------------------------------------
    */

    public function destroy(int $id)
    {
        // Make sure content exists
        DB::table('admins_tips')
            ->where('id', $id)
            ->firstOrFail();

        try {

            // Permanently delete selected content
            $deleted = DB::table('admins_tips')
                ->where('id', $id)
                ->delete();

        } catch (QueryException $e) {

            // Log database error
            report($e);

            return redirect()
                ->route('admin.tips.show', ['id' => $id])
                ->with(
                    'error',
                    'Content could not be deleted. Please check related database records.'
                );
        }

        // Handle unsuccessful delete
        if ($deleted === 0) {

            return redirect()
                ->route('admin.tips.index')
                ->with(
                    'error',
                    'Content was not deleted. It may already have been removed.'
                );
        }

        // Return to Manage Tips & Articles
        return redirect()
            ->route('admin.tips.index')
            ->with(
                'success',
                'Content deleted successfully.'
            );
    }
}
