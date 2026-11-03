<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class UserController extends Controller
{
    // Display users, search and filter
    public function index(Request $request)
    {
        // Validate search and status filter
        $validated = $request->validate([
            'search' => 'nullable|string|max:100',
            'status' => 'nullable|in:all,active,inactive',
        ]);

        // Get search keyword
        $search = trim($validated['search'] ?? '');

        // Get selected account status
        $status = $validated['status'] ?? 'all';

        // Get users from database
        $query = DB::table('users')
            ->select(
                'id',
                'username',
                'email',
                'account_status',
                'last_login_at',
                'created_at'
            );

        // Search by username or email
        if ($search !== '') {

            $query->where(function ($q) use ($search) {

                $q->where(
                    'username',
                    'LIKE',
                    "%{$search}%"
                )
                ->orWhere(
                    'email',
                    'LIKE',
                    "%{$search}%"
                );

            });
        }

        // Filter users by account status
        if ($status === 'active' || $status === 'inactive') {

            $query->where('account_status', $status);

        }

        // Sort and paginate users
        $users = $query
            ->orderBy('id', 'desc')
            ->paginate(10)
            ->withQueryString();

        // Display Manage Users page
        return view('admin.users.index', compact(
            'users',
            'search',
            'status'
        ));
    }

    // Display specific user details
    public function show(int $id)
    {
        // Find user by ID
        $user = DB::table('users')
            ->select(
                'id',
                'username',
                'email',
                'account_status',
                'last_login_at',
                'created_at'
            )
            ->where('id', $id)
            ->firstOrFail();

        // Display User Details page
        return view('admin.users.show', compact(
            'user'
        ));
    }

    // Activate or deactivate user account
    public function updateStatus(Request $request, int $id)
    {
        // Validate account status
        $validated = $request->validate([
            'account_status' => 'required|in:active,inactive',
        ]);

        // Make sure user exists
        $user = DB::table('users')
            ->where('id', $id)
            ->firstOrFail();

        // Update user account status
        DB::table('users')
            ->where('id', $user->id)
            ->update([
                'account_status' => $validated['account_status']
            ]);

        // Prepare success message
        $message = $validated['account_status'] === 'active'
            ? 'User account activated successfully.'
            : 'User account deactivated successfully.';

        // Return to User Details
        return redirect()
            ->route('admin.users.show', ['id' => $id])
            ->with('success', $message);
    }
}
