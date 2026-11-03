
@extends('admin.layouts.app')

@section('title', 'Manage Replies')

@section('page-title', 'Manage Journal Replies')

@push('styles')
<style>
    .reply-stat-card {
        background: #ffffff;
        border-radius: 12px;
        padding: 25px;
        border-left: 4px solid #5271a5;
        box-shadow: 0 3px 12px rgba(0,0,0,0.05);
        margin-bottom: 25px;
    }

    .reply-stat-card h6 {
        color: #777;
        margin-bottom: 12px;
    }

    .reply-stat-card h2 {
        color: #344e7a;
        font-size: 36px;
        font-weight: bold;
        margin-bottom: 0;
    }

    .reply-search-section {
        background: #f8fafd;
        border: 1px solid #e3eaf4;
        padding: 20px;
        border-radius: 10px;
        margin-bottom: 25px;
    }

    .reply-table th,
    .reply-table td {
        vertical-align: middle;
        padding: 14px 12px;
    }

    .reply-content {
        white-space: pre-wrap;
        overflow-wrap: anywhere;
        color: #444;
    }

    .journal-title {
        color: #344e7a;
        font-weight: 600;
        overflow-wrap: anywhere;
    }

    .empty-replies {
        padding: 35px 15px;
        text-align: center;
        color: #777;
    }

    .reply-note {
        background: #eef4fb;
        padding: 18px;
        border-radius: 10px;
        color: #52627a;
        margin-top: 25px;
    }

    .reply-actions {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
    }
</style>
@endpush

@section('content')

<!-- Total Replies -->
<div class="reply-stat-card">

    <h6>
        Total Journal Replies
    </h6>

    <h2>
        {{ number_format($totalReplies) }}
    </h2>

</div>


<!-- Main Replies List -->
<div class="content-card">

    <!-- Success Message -->
    @if (session('success'))

        <div class="alert alert-success">
            {{ session('success') }}
        </div>

    @endif

    <!-- Error Message -->
    @if (session('error'))

        <div class="alert alert-danger">
            {{ session('error') }}
        </div>

    @endif

    <!-- Validation Errors -->
    @if ($errors->any())

        <div class="alert alert-danger">
            {{ $errors->first() }}
        </div>

    @endif


    <!-- Page Header -->
    <div class="d-flex justify-content-between
                align-items-center flex-wrap gap-3 mb-4">

        <div>

            <h5 class="mb-1">
                All Journal Replies
            </h5>

            <p class="text-muted mb-0">
                View and search replies posted
                in the SafeSpace journal community.
            </p>

        </div>

        <span class="badge bg-primary">
            Results: {{ $replies->total() }}
        </span>

    </div>


    <!-- Search Section -->
    <div class="reply-search-section">

        <form
            method="GET"
            action="{{ route('admin.replies.index') }}"
        >

            <label
                for="search"
                class="form-label fw-semibold">

                Search Replies

            </label>

            <div class="row g-2">

                <!-- Search Input -->
                <div class="col-md-8">

                    <input
                        type="text"
                        name="search"
                        id="search"
                        class="form-control"
                        placeholder="Search reply content or journal title..."
                        value="{{ $search }}"
                        maxlength="100"
                    >

                </div>

                <!-- Search Button -->
                <div class="col-md-2">

                    <button
                        type="submit"
                        class="btn btn-primary w-100">

                        Search

                    </button>

                </div>

                <!-- Clear Button -->
                <div class="col-md-2">

                    <a
                        href="{{ route('admin.replies.index') }}"
                        class="btn btn-outline-secondary w-100">

                        Clear

                    </a>

                </div>

            </div>

        </form>

    </div>


    <!-- Search Result Information -->
    @if ($search !== '')

        <div class="alert alert-info">

            Search results for:
            <strong>{{ $search }}</strong>

            <br>

            Found {{ $replies->total() }} reply/replies.

        </div>

    @endif


    <!-- Replies Table -->
    <div class="table-responsive">

        <table class="table table-hover reply-table">

            <thead>

                <tr>
                    <th>Reply ID</th>
                    <th>Journal</th>
                    <th>Content Preview</th>
                    <th>Posted Date</th>
                    <th>Action</th>
                </tr>

            </thead>

            <tbody>

                @forelse ($replies as $reply)

                    <tr>

                        <!-- Reply ID -->
                        <td>

                            <strong>
                                #{{ $reply->id }}
                            </strong>

                        </td>


                        <!-- Related Journal -->
                        <td>

                            @if ($reply->journal_title !== null)

                                <div class="journal-title">
                                    {{ $reply->journal_title ?: 'Untitled Journal' }}
                                </div>

                                <small class="text-muted">
                                    Journal #{{ $reply->journal_id }}
                                </small>

                            @else

                                <span class="text-muted">
                                    Journal Unavailable
                                </span>

                            @endif

                        </td>


                        <!-- Reply Content Preview -->
                        <td style="min-width: 250px;">

                            <div class="reply-content">{{ \Illuminate\Support\Str::limit($reply->content, 120) }}</div>

                        </td>


                        <!-- Posted Date -->
                        <td>

                            @if ($reply->created_at)

                                {{ \Carbon\Carbon::parse($reply->created_at)->format('d M Y, h:i A') }}

                            @else

                                -

                            @endif

                        </td>


                        <!-- Action Buttons -->
                        <td>

                            <div class="reply-actions">

                                <!-- View Reply Details -->
                                <a
                                    href="{{ route('admin.replies.show', ['id' => $reply->id]) }}"
                                    class="btn btn-sm btn-primary text-nowrap">

                                    View Details

                                </a>

                                <!-- Open Related Journal -->
                                @if ($reply->journal_title !== null)

                                    <a
                                        href="{{ route('admin.journals.show', ['id' => $reply->journal_id]) }}"
                                        class="btn btn-sm btn-outline-primary text-nowrap">

                                        Open Journal

                                    </a>

                                @endif

                            </div>

                        </td>

                    </tr>

                @empty

                    <!-- No Replies -->
                    <tr>

                        <td colspan="5">

                            <div class="empty-replies">

                                @if ($search !== '')

                                    <h5 class="mb-2">
                                        No Matching Replies
                                    </h5>

                                    <p class="mb-0">
                                        No replies match your search.

                                        Try another keyword
                                        or click Clear.
                                    </p>

                                @else

                                    <h5 class="mb-2">
                                        No Replies Found
                                    </h5>

                                    <p class="mb-0">
                                        No journal replies
                                        have been posted yet.

                                        Replies will appear here
                                        when users start interacting
                                        through the SafeSpace Mobile App.
                                    </p>

                                @endif

                            </div>

                        </td>

                    </tr>

                @endforelse

            </tbody>

        </table>

    </div>


    <!-- Pagination -->
    @if ($replies->hasPages())

        <div class="mt-4">

            {{ $replies->links('pagination::bootstrap-5') }}

        </div>

    @endif

</div>


<!-- Information Note -->
<div class="reply-note">

    <strong>
        Journal Reply Management
    </strong>

    <p class="mb-0 mt-2">
        Select View Details to inspect a journal reply.

        Admin can remove inappropriate replies
        using the Delete Reply function.

        Deleted replies cannot be recovered
        through this administration system.
    </p>

</div>

@endsection
