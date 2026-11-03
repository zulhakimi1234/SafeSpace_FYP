
@extends('admin.layouts.app')

@section('title', 'Admin Dashboard')

@section('page-title', 'Admin Dashboard')

@push('styles')
<style>
    /* Dashboard Statistics Cards */
    .dashboard-card {
        background: #ffffff;
        padding: 25px;
        border-radius: 12px;
        border-left: 4px solid #5271a5;
        box-shadow: 0 3px 12px rgba(0,0,0,0.05);
        height: 100%;
    }

    .dashboard-card h6 {
        color: #777;
        margin-bottom: 15px;
    }

    .dashboard-card h2 {
        color: #344e7a;
        font-size: 36px;
        font-weight: bold;
        margin-bottom: 10px;
    }

    .dashboard-card small {
        color: #888;
    }

    /* Active Users */
    .card-active {
        border-left-color: #198754;
    }

    .card-active h2 {
        color: #198754;
    }

    /* Inactive Users */
    .card-inactive {
        border-left-color: #dc3545;
    }

    .card-inactive h2 {
        color: #dc3545;
    }

    /* Normal Journals */
    .card-normal {
        border-left-color: #198754;
    }

    .card-normal h2 {
        color: #198754;
    }

    /* Hidden Journals */
    .card-hidden {
        border-left-color: #e0a800;
    }

    .card-hidden h2 {
        color: #bd8c00;
    }

    /* Journal Replies */
    .card-replies {
        border-left-color: #8059b7;
    }

    .card-replies h2 {
        color: #8059b7;
    }

    /* Pending Reports */
    .card-pending {
        border-left-color: #ffc107;
    }

    .card-pending h2 {
        color: #bd8c00;
    }

    /* Reviewed Reports */
    .card-reviewed {
        border-left-color: #0dcaf0;
    }

    .card-reviewed h2 {
        color: #087e96;
    }

    /* Resolved Reports */
    .card-resolved {
        border-left-color: #198754;
    }

    .card-resolved h2 {
        color: #198754;
    }

    /*
    |--------------------------------------------------------------------------
    | NEW TIPS & ARTICLES CARDS
    |--------------------------------------------------------------------------
    */

    /* Total Tips */
    .card-tips {
        border-left-color: #5271a5;
    }

    .card-tips h2 {
        color: #5271a5;
    }

    /* Total Articles */
    .card-articles {
        border-left-color: #8059b7;
    }

    .card-articles h2 {
        color: #8059b7;
    }

    /* Published Content */
    .card-published {
        border-left-color: #198754;
    }

    .card-published h2 {
        color: #198754;
    }

    /* Draft Content */
    .card-draft {
        border-left-color: #e0a800;
    }

    .card-draft h2 {
        color: #bd8c00;
    }

    /*
    |--------------------------------------------------------------------------
    | OVERVIEW SECTIONS
    |--------------------------------------------------------------------------
    */

    .overview-card {
        background: #ffffff;
        padding: 25px;
        border-radius: 12px;
        box-shadow: 0 3px 12px rgba(0,0,0,0.05);
    }

    .overview-card h5 {
        color: #344e7a;
        font-weight: 600;
    }

    .btn-overview {
        background: #5271a5;
        color: #ffffff;
        padding: 10px 20px;
        border-radius: 8px;
        text-decoration: none;
        display: inline-block;
    }

    .btn-overview:hover {
        background: #344e7a;
        color: #ffffff;
    }

    .status-summary {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
        margin: 18px 0;
    }

    .status-summary .badge {
        font-size: 13px;
        padding: 9px 13px;
    }

    .welcome-section {
        background: #eef4fb;
        padding: 25px;
        border-radius: 12px;
    }

    .overview-stat {
        background: #f8fafd;
        border: 1px solid #e3eaf4;
        border-radius: 10px;
        padding: 15px;
        height: 100%;
    }

    .overview-stat strong {
        color: #344e7a;
        font-size: 22px;
    }
</style>
@endpush

@section('content')

<!-- Dashboard Statistics -->
<div class="row g-4">

    <!-- Total Users -->
    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card">

            <h6>Total Users</h6>

            <h2>
                {{ number_format($totalUsers) }}
            </h2>

            <small>
                Registered SafeSpace Users
            </small>

        </div>
    </div>


    <!-- Active Users -->
    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card card-active">

            <h6>Total Active Users</h6>

            <h2>
                {{ number_format($totalActiveUsers) }}
            </h2>

            <small>
                Currently Active Accounts
            </small>

        </div>
    </div>


    <!-- Inactive Users -->
    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card card-inactive">

            <h6>Total Inactive Users</h6>

            <h2>
                {{ number_format($totalInactiveUsers) }}
            </h2>

            <small>
                Deactivated User Accounts
            </small>

        </div>
    </div>


    <!-- Total Journal Posts -->
    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card">

            <h6>Total Journal Posts</h6>

            <h2>
                {{ number_format($totalPosts) }}
            </h2>

            <small>
                Shared Journal Entries
            </small>

        </div>
    </div>


    <!-- Normal Journals -->
    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card card-normal">

            <h6>Normal Journals</h6>

            <h2>
                {{ number_format($totalNormalJournals) }}
            </h2>

            <small>
                Journals Not Hidden by Moderation
            </small>

        </div>
    </div>


    <!-- Hidden Journals -->
    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card card-hidden">

            <h6>Hidden Journals</h6>

            <h2>
                {{ number_format($totalHiddenJournals) }}
            </h2>

            <small>
                Journals Hidden by Admin
            </small>

        </div>
    </div>


    <!-- Total Journal Replies -->
    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card card-replies">

            <h6>Total Journal Replies</h6>

            <h2>
                {{ number_format($totalReplies) }}
            </h2>

            <small>
                Community Journal Replies
            </small>

        </div>
    </div>


    <!-- Total Mood Records -->
    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card">

            <h6>Total Mood Records</h6>

            <h2>
                {{ number_format($totalMoodRecords) }}
            </h2>

            <small>
                Valid Mood Check-ins
            </small>

        </div>
    </div>


    <!-- Average Mood Score -->
    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card">

            <h6>Average Mood Score</h6>

            <h2>
                @if ($averageMoodScore !== null)

                    {{ number_format($averageMoodScore, 2) }}

                @else

                    N/A

                @endif
            </h2>

            <small>
                Average Score Out of 5
            </small>

        </div>
    </div>


    <!-- Total Reports -->
    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card">

            <h6>Total Reports</h6>

            <h2>
                {{ number_format($totalReports) }}
            </h2>

            <small>
                Reports Submitted by Users
            </small>

        </div>
    </div>


    <!-- Pending Reports -->
    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card card-pending">

            <h6>Pending Reports</h6>

            <h2>
                {{ number_format($pendingReports) }}
            </h2>

            <small>
                Waiting for Admin Review
            </small>

        </div>
    </div>


    <!-- Reviewed Reports -->
    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card card-reviewed">

            <h6>Reviewed Reports</h6>

            <h2>
                {{ number_format($reviewedReports) }}
            </h2>

            <small>
                Reports Already Reviewed
            </small>

        </div>
    </div>


    <!-- Resolved Reports -->
    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card card-resolved">

            <h6>Resolved Reports</h6>

            <h2>
                {{ number_format($resolvedReports) }}
            </h2>

            <small>
                Completed Report Reviews
            </small>

        </div>
    </div>


    <!-- NEW: Total Tips -->
    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card card-tips">

            <h6>Total Tips</h6>

            <h2>
                {{ number_format($totalTips) }}
            </h2>

            <small>
                Emotional Support Tips
            </small>

        </div>
    </div>


    <!-- NEW: Total Articles -->
    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card card-articles">

            <h6>Total Articles</h6>

            <h2>
                {{ number_format($totalArticles) }}
            </h2>

            <small>
                Emotional Support Articles
            </small>

        </div>
    </div>


    <!-- NEW: Published Content -->
    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card card-published">

            <h6>Published Content</h6>

            <h2>
                {{ number_format($totalPublishedContent) }}
            </h2>

            <small>
                Published Tips &amp; Articles
            </small>

        </div>
    </div>


    <!-- NEW: Draft Content -->
    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card card-draft">

            <h6>Draft Content</h6>

            <h2>
                {{ number_format($totalDraftContent) }}
            </h2>

            <small>
                Unpublished Tips &amp; Articles
            </small>

        </div>
    </div>

</div>


<!-- User Account Overview -->
<div class="overview-card mt-4">

    <h5 class="mb-3">
        User Account Overview
    </h5>

    @if ($totalUsers > 0)

        <p class="text-muted">
            SafeSpace currently has
            <strong>{{ number_format($totalUsers) }}</strong>
            registered users.

            There are
            <strong>{{ number_format($totalActiveUsers) }}</strong>
            active accounts and
            <strong>{{ number_format($totalInactiveUsers) }}</strong>
            inactive accounts.
        </p>

    @else

        <p class="text-muted">
            No registered users available yet.

            User statistics will appear automatically
            when users register through the
            SafeSpace Mobile App.
        </p>

    @endif

    <a
        href="{{ route('admin.users.index') }}"
        class="btn-overview"
    >
        Manage Users &rarr;
    </a>

</div>


<!-- Journal Moderation Overview -->
<div class="overview-card mt-4">

    <h5 class="mb-3">
        Journal Moderation Overview
    </h5>

    @if ($totalPosts > 0)

        <p class="text-muted">
            SafeSpace currently has
            <strong>{{ number_format($totalPosts) }}</strong>
            journal posts.

            Among these,
            <strong>{{ number_format($totalNormalJournals) }}</strong>
            journals have normal moderation status,
            and
            <strong>{{ number_format($totalHiddenJournals) }}</strong>
            journals are hidden by admin.
        </p>

    @else

        <p class="text-muted">
            No journal posts available yet.

            Journal statistics will appear
            automatically when users start
            posting journal entries.
        </p>

    @endif

    <a
        href="{{ route('admin.journals.index') }}"
        class="btn-overview"
    >
        Manage Journals &rarr;
    </a>

</div>


<!-- Journal Replies Overview -->
<div class="overview-card mt-4">

    <h5 class="mb-3">
        Journal Replies Overview
    </h5>

    @if ($totalReplies > 0)

        <p class="text-muted">
            SafeSpace currently has
            <strong>{{ number_format($totalReplies) }}</strong>
            journal replies.

            Admin can review journal replies,
            view their details and remove
            inappropriate replies.
        </p>

    @else

        <p class="text-muted">
            No journal replies available yet.

            Reply statistics will appear
            automatically when users start
            responding to community journals.
        </p>

    @endif

    <a
        href="{{ route('admin.replies.index') }}"
        class="btn-overview"
    >
        Manage Replies &rarr;
    </a>

</div>


<!-- Mood Check-in Overview -->
<div class="overview-card mt-4">

    <h5 class="mb-3">
        Mood Check-in Overview
    </h5>

    @if ($totalMoodRecords > 0)

        <p class="text-muted">
            SafeSpace users have recorded
            <strong>{{ number_format($totalMoodRecords) }}</strong>
            mood check-ins.

            The current average mood score is
            <strong>{{ number_format($averageMoodScore, 2) }}</strong>
            out of 5.
        </p>

    @else

        <p class="text-muted">
            No mood records available yet.

            Mood statistics will appear
            automatically when users start
            recording their mood.
        </p>

    @endif

    <a
        href="{{ route('admin.moods.index') }}"
        class="btn-overview"
    >
        View Mood Statistics &rarr;
    </a>

</div>


<!-- Report Management Overview -->
<div class="overview-card mt-4">

    <h5 class="mb-3">
        Report Management Overview
    </h5>

    @if ($totalReports > 0)

        <p class="text-muted">
            SafeSpace currently has
            <strong>{{ number_format($totalReports) }}</strong>
            user-submitted reports.

            Admin can review pending reports,
            examine reported content and
            update report status.
        </p>

        <!-- Report Status Summary -->
        <div class="status-summary">

            <span class="badge bg-warning text-dark">
                Pending:
                {{ number_format($pendingReports) }}
            </span>

            <span class="badge bg-info text-dark">
                Reviewed:
                {{ number_format($reviewedReports) }}
            </span>

            <span class="badge bg-success">
                Resolved:
                {{ number_format($resolvedReports) }}
            </span>

        </div>

        @if ($pendingReports > 0)

            <div class="alert alert-warning">
                There are
                <strong>{{ number_format($pendingReports) }}</strong>
                pending reports awaiting admin review.
            </div>

        @endif

    @else

        <p class="text-muted">
            No reports have been submitted yet.

            Report statistics will appear
            automatically when users start
            reporting journals or replies.
        </p>

    @endif

    <a
        href="{{ route('admin.reports.index') }}"
        class="btn-overview"
    >
        Manage Reports &rarr;
    </a>

</div>


<!-- NEW: Tips and Articles Overview -->
<div class="overview-card mt-4">

    <h5 class="mb-3">
        Tips &amp; Articles Overview
    </h5>

    @if ($totalContent > 0)

        <p class="text-muted">
            SafeSpace currently has
            <strong>{{ number_format($totalContent) }}</strong>
            emotional support content records
            managed by administrators.
        </p>

        <!-- Content Statistics Summary -->
        <div class="row g-3 mb-4">

            <!-- Tips -->
            <div class="col-sm-6 col-xl-3">
                <div class="overview-stat">

                    <div class="text-muted mb-2">
                        Tips
                    </div>

                    <strong>
                        {{ number_format($totalTips) }}
                    </strong>

                </div>
            </div>

            <!-- Articles -->
            <div class="col-sm-6 col-xl-3">
                <div class="overview-stat">

                    <div class="text-muted mb-2">
                        Articles
                    </div>

                    <strong>
                        {{ number_format($totalArticles) }}
                    </strong>

                </div>
            </div>

            <!-- Published -->
            <div class="col-sm-6 col-xl-3">
                <div class="overview-stat">

                    <div class="text-muted mb-2">
                        Published
                    </div>

                    <strong class="text-success">
                        {{ number_format($totalPublishedContent) }}
                    </strong>

                </div>
            </div>

            <!-- Draft -->
            <div class="col-sm-6 col-xl-3">
                <div class="overview-stat">

                    <div class="text-muted mb-2">
                        Drafts
                    </div>

                    <strong>
                        {{ number_format($totalDraftContent) }}
                    </strong>

                </div>
            </div>

        </div>

        @if ($totalDraftContent > 0)

            <div class="alert alert-info">
                There are
                <strong>{{ number_format($totalDraftContent) }}</strong>
                draft content records that can be
                reviewed before publication.
            </div>

        @endif

        <p class="text-muted">
            Admin can create, view, edit, delete
            and manage the publication status
            of Tips and Articles.
        </p>

    @else

        <p class="text-muted">
            No tips or articles have been created yet.

            Content statistics will appear
            automatically when admin starts
            adding Tips or Articles through
            Manage Tips &amp; Articles.
        </p>

    @endif

    <!-- Manage Tips Button -->
    <a
        href="{{ route('admin.tips.index') }}"
        class="btn-overview"
    >
        Manage Tips &amp; Articles &rarr;
    </a>

</div>


<!-- Welcome Section -->
<div class="welcome-section mt-4">

    <h5 class="mb-3">
        Welcome to SafeSpace Administration
    </h5>

    <p class="text-muted mb-0">
        Monitor registered users,
        account status,
        anonymous community journals,
        journal replies,
        journal moderation activities,
        mood statistics,
        user-submitted reports,
        and emotional support Tips &amp; Articles
        through the SafeSpace Admin Dashboard.
    </p>

</div>

@endsection
