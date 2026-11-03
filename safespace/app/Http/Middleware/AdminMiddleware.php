<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class AdminMiddleware
{
    public function handle(
        Request $request,
        Closure $next
    ): Response {

        // Check if admin is logged in
        if (!Auth::guard('admin')->check()) {

            // Redirect unauthenticated users
            return redirect()->route('admin.login');
        }

        // Allow authenticated admin to proceed
        return $next($request);
    }
}
