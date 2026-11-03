
<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\JournalController;
use App\Http\Controllers\Admin\ReplyController;
use App\Http\Controllers\Admin\MoodController;
use App\Http\Controllers\Admin\ReportController;
use App\Http\Controllers\Admin\TipController;

use App\Http\Middleware\AdminMiddleware;

/*
|--------------------------------------------------------------------------
| ADMIN LOGIN ROUTES
|--------------------------------------------------------------------------
*/

Route::get('/admin/login', [
    AuthController::class, 'showLogin'
])->name('admin.login');

Route::post('/admin/login', [
    AuthController::class, 'login'
])->name('admin.login.submit');


/*
|--------------------------------------------------------------------------
| PROTECTED ADMIN ROUTES
|--------------------------------------------------------------------------
*/

Route::middleware([AdminMiddleware::class])
    ->prefix('admin')
    ->name('admin.')
    ->group(function () {

        /*
        |--------------------------------------------------------------------------
        | DASHBOARD
        |--------------------------------------------------------------------------
        */

        Route::get('/dashboard', [
            DashboardController::class, 'index'
        ])->name('dashboard');


        /*
        |--------------------------------------------------------------------------
        | MANAGE USERS
        |--------------------------------------------------------------------------
        */

        Route::get('/users', [
            UserController::class, 'index'
        ])->name('users.index');

        Route::get('/users/{id}', [
            UserController::class, 'show'
        ])
        ->whereNumber('id')
        ->name('users.show');

        Route::patch('/users/{id}/status', [
            UserController::class, 'updateStatus'
        ])
        ->whereNumber('id')
        ->name('users.updateStatus');


        /*
        |--------------------------------------------------------------------------
        | MANAGE JOURNALS
        |--------------------------------------------------------------------------
        */

        Route::get('/journals', [
            JournalController::class, 'index'
        ])->name('journals.index');

        Route::get('/journals/{id}', [
            JournalController::class, 'show'
        ])
        ->whereNumber('id')
        ->name('journals.show');

        Route::patch('/journals/{id}/moderation', [
            JournalController::class, 'updateModerationStatus'
        ])
        ->whereNumber('id')
        ->name('journals.updateModerationStatus');

        Route::delete('/journals/{id}', [
            JournalController::class, 'destroy'
        ])
        ->whereNumber('id')
        ->name('journals.destroy');


        /*
        |--------------------------------------------------------------------------
        | MANAGE JOURNAL REPLIES
        |--------------------------------------------------------------------------
        */

        Route::get('/replies', [
            ReplyController::class, 'index'
        ])->name('replies.index');

        Route::get('/replies/{id}', [
            ReplyController::class, 'show'
        ])
        ->whereNumber('id')
        ->name('replies.show');

        Route::delete('/replies/{id}', [
            ReplyController::class, 'destroy'
        ])
        ->whereNumber('id')
        ->name('replies.destroy');


        /*
        |--------------------------------------------------------------------------
        | MANAGE MOOD RECORDS
        |--------------------------------------------------------------------------
        */

        Route::get('/moods', [
            MoodController::class, 'index'
        ])->name('moods.index');


        /*
        |--------------------------------------------------------------------------
        | MANAGE REPORTS
        |--------------------------------------------------------------------------
        */

        Route::get('/reports', [
            ReportController::class, 'index'
        ])->name('reports.index');

        Route::get('/reports/{id}', [
            ReportController::class, 'show'
        ])
        ->whereNumber('id')
        ->name('reports.show');

        Route::patch('/reports/{id}/status', [
            ReportController::class, 'updateStatus'
        ])
        ->whereNumber('id')
        ->name('reports.updateStatus');


        /*
        |--------------------------------------------------------------------------
        | MANAGE TIPS AND ARTICLES
        |--------------------------------------------------------------------------
        */

        // Display content list
        Route::get('/tips', [
            TipController::class, 'index'
        ])->name('tips.index');

        // Display create form
        Route::get('/tips/create', [
            TipController::class, 'create'
        ])->name('tips.create');

        // Store new content
        Route::post('/tips', [
            TipController::class, 'store'
        ])->name('tips.store');

        // Display edit form
        Route::get('/tips/{id}/edit', [
            TipController::class, 'edit'
        ])
        ->whereNumber('id')
        ->name('tips.edit');

        // Update existing content
        Route::put('/tips/{id}', [
            TipController::class, 'update'
        ])
        ->whereNumber('id')
        ->name('tips.update');

        // View content details
        Route::get('/tips/{id}', [
            TipController::class, 'show'
        ])
        ->whereNumber('id')
        ->name('tips.show');

        // Delete tip or article
        Route::delete('/tips/{id}', [
            TipController::class, 'destroy'
        ])
        ->whereNumber('id')
        ->name('tips.destroy');


        /*
        |--------------------------------------------------------------------------
        | ADMIN LOGOUT
        |--------------------------------------------------------------------------
        */

        Route::post('/logout', function (Request $request) {

            Auth::guard('admin')->logout();

            $request->session()->invalidate();
            $request->session()->regenerateToken();

            return redirect()
                ->route('admin.login')
                ->with(
                    'success',
                    'You have logged out successfully.'
                );

        })->name('logout');

    });
