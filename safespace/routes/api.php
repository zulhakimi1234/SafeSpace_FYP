
<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\MobileAuthController;
use App\Http\Controllers\Api\MobileJournalController;
use App\Http\Controllers\Api\MobileMoodController;
use App\Http\Controllers\Api\MobileAssessmentController;
use App\Http\Controllers\Api\MobileTaskController;
use App\Http\Controllers\Api\MobileWellnessController;
use App\Http\Controllers\Api\MobileChatController;

// ==========================================
// API CONNECTION TEST
// ==========================================

Route::get('/ping', function () {
    return response()->json([
        'status' => 'success',
        'message' =>
            'SafeSpace API connected successfully!',
    ]);
});

// ==========================================
// PUBLIC AUTHENTICATION
// ==========================================

Route::post(
    '/register',
    [MobileAuthController::class, 'register']
)->middleware('throttle:5,1');

Route::post(
    '/login',
    [MobileAuthController::class, 'login']
)->middleware('throttle:5,1');

// ==========================================
// AUTHENTICATED MOBILE ROUTES
// ==========================================

Route::middleware('auth:sanctum')->group(function () {

    // Authentication
    Route::get(
        '/user',
        [MobileAuthController::class, 'me']
    );

    Route::post(
        '/logout',
        [MobileAuthController::class, 'logout']
    );

    // ======================================
    // COMMUNITY JOURNAL
    // ======================================

    Route::get(
        '/journals',
        [MobileJournalController::class, 'index']
    );

    Route::post(
        '/journals',
        [MobileJournalController::class, 'store']
    )->middleware('throttle:10,1');

    Route::post(
        '/journals/{id}/replies',
        [MobileJournalController::class, 'reply']
    )->whereNumber('id')
     ->middleware('throttle:20,1');

    Route::get(
        '/journals/{id}',
        [MobileJournalController::class, 'show']
    )->whereNumber('id');

    Route::delete(
        '/journals/{id}',
        [MobileJournalController::class, 'destroy']
    )->whereNumber('id');

    // ======================================
    // MOOD HISTORY
    // ======================================

    Route::get(
        '/moods',
        [MobileMoodController::class, 'index']
    );

    // ======================================
    // SELF-ASSESSMENT
    // ======================================

    Route::get(
        '/assessments',
        [MobileAssessmentController::class, 'index']
    );

    Route::get(
        '/assessments/{id}',
        [MobileAssessmentController::class, 'show']
    )->whereNumber('id');

    Route::post(
        '/assessments/{id}/submit',
        [MobileAssessmentController::class, 'submit']
    )->whereNumber('id')
     ->middleware('throttle:10,1');

    // ======================================
    // TASKS & CALENDAR
    // ======================================

    Route::get(
        '/tasks',
        [MobileTaskController::class, 'index']
    );

    Route::post(
        '/tasks',
        [MobileTaskController::class, 'store']
    )->middleware('throttle:30,1');

    Route::get(
        '/tasks/{id}',
        [MobileTaskController::class, 'show']
    )->whereNumber('id');

    Route::put(
        '/tasks/{id}',
        [MobileTaskController::class, 'update']
    )->whereNumber('id');

    Route::delete(
        '/tasks/{id}',
        [MobileTaskController::class, 'destroy']
    )->whereNumber('id');

    // ======================================
    // WELLNESS RESOURCES
    // ======================================

    Route::get(
        '/wellness',
        [MobileWellnessController::class, 'index']
    );

    Route::get(
        '/wellness/{id}',
        [MobileWellnessController::class, 'show']
    )->whereNumber('id');

    // ======================================
    // AI CHATBOT - OLLAMA LLAMA3
    // ======================================

    Route::post(
        '/chat',
        [MobileChatController::class, 'send']
    )->middleware('throttle:10,1');
});
