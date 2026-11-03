
@extends('admin.layouts.app')

@section('title', 'Reply Details')

@section('page-title', 'Reply Details')

@push('styles')
<style>
    .reply-header {
        background: #f0f4fa;
        padding: 25px;
        border-radius: 12px;
        margin-bottom: 25px;
    }

    .reply-heading {
        color: #344e7a;
        font-weight: bold;
    }

    .reply-info-row {
        padding: 18px 0;
        border-bottom: 1px solid #e9ecef;
    }

    .reply-label {
        color: #777;
        font-weight: 500;
    }

    .reply-value {
        color: #344e7a;
        font-weight: 600;
        overflow-wrap: anywhere;
    }

    .reply-section {
        margin-top: 28px;
    }

    .reply-section h5 {
        color: #344e7a;
        font-weight: 600;
        margin-bottom: 15px;
    }

    .reply-content-box {
        background: #fafbfd;
        border: 1px solid #e6ebf2;
        border-radius: 12px;
        padding: 25px;
        white-space: pre-wrap;
        overflow-wrap: anywhere;
        line-height: 1.9;
        color: #333;
    }

    .journal-info-box {
        background: #f8fafd;
        border: 1px solid #e3eaf4;
        padding: 25px;
        border-radius: 12px;
    }

    .journal-title {
        color: #344e7a;
        font-weight: 600;
        overflow-wrap: anywhere;
    }

    .delete-section {
        margin-top: 30px;
        padding: 25px;
        background: #fffafa;
        border: 1px solid #f1c5c5;
        border-radius: 12px;
    }

    .delete-section h5 {
        color: #dc3545;
        font-weight: 600;
    }

    .delete-button {
        padding: 10px 22px;
        border-radius: 8px;
        font-weight: 600;
    }

    .privacy-note {
        background: #eef4fb;
        padding: 18px;
        border-radius: 10px;
        color: #52627a;
        margin-top: 28px;
    }

    .btn-back {
        background: #5271a5;
        color: white;
        padding: 10px 20px;
        border-radius: 8px;
        text-decoration: none;
        display: inline-block;
    }

    .btn-back:hover {
        background: #344e7a;
        color: white;
    }
</style>
@endpush

@section('content')

<div class="content-card">

    <!-- Error Message -->
    @if (session('error'))

        <div class="alert alert-danger">
            {{ session('error') }}
        </div>

    @endif


    <!-- Reply Header -->
    <div class="reply-header">

        <h4 class="reply-heading mb-2">
            Reply #{{ $reply->id }}
        </h4>

        <p class="text-muted mb-0">
            SafeSpace Community Journal Reply
        </p>

    </div>


    <!-- Reply Information -->
    <h5 class="mb-3">
        Reply Information
    </h5>


    <!-- Reply ID -->
    <div class="row reply-info-row">

        <div class="col-md-4 reply-label">
            Reply ID
        </div>

        <div class="col-md-8 reply-value">
            #{{ $reply->id }}
        </div>

    </div>


    <!-- Related Journal ID -->
    <div class="row reply-info-row">

        <div class="col-md-4 reply-label">
            Related Journal ID
        </div>

        <div class="col-md-8 reply-value">
            #{{ $reply->journal_id }}
        </div>

    </div>


    <!-- Posted Date -->
    <div class="row reply-info-row">

        <div class="col-md-4 reply-label">
            Posted Date
        </div>

        <div class="col-md-8 reply-value">

            @if ($reply->created_at)

                {{ \Carbon\Carbon::parse($reply->created_at)->format('d M Y, h:i A') }}

            @else

                -

            @endif

        </div>

    </div>


    <!-- Last Updated -->
    <div class="row reply-info-row">

        <div class="col-md-4 reply-label">
            Last Updated
        </div>

        <div class="col-md-8 reply-value">

            @if ($reply->updated_at)

                {{ \Carbon\Carbon::parse($reply->updated_at)->format('d M Y, h:i A') }}

            @else

                -

            @endif

        </div>

    </div>


    <!-- Full Reply Content -->
    <div class="reply-section">

        <h5>
            Reply Content
        </h5>

        <div class="reply-content-box">{{ $reply->content }}</div>

    </div>


    <!-- Related Journal Information -->
    <div class="reply-section">

        <h5>
            Related Journal
        </h5>

        @if ($journal !== null)

            <div class="journal-info-box">

                <div class="d-flex justify-content-between
                            align-items-center flex-wrap gap-3 mb-3">

                    <strong class="journal-title">
                        Journal #{{ $journal->id }}
                    </strong>

                    <!-- Journal Moderation Status -->
                    @if ($journal->moderation_status === 'normal')

                        <span class="badge bg-success">
                            Normal
                        </span>

                    @elseif ($journal->moderation_status === 'hidden')

                        <span class="badge bg-warning text-dark">
                            Hidden
                        </span>

                    @else

                        <span class="badge bg-secondary">
                            Unknown
                        </span>

                    @endif

                </div>

                <!-- Journal Title -->
                <h5 class="journal-title">
                    {{ $journal->title ?: 'Untitled Journal' }}
                </h5>

                <!-- Journal Date -->
                <p class="text-muted mt-2">

                    @if ($journal->created_at)

                        Posted on
                        {{ \Carbon\Carbon::parse($journal->created_at)->format('d M Y, h:i A') }}

                    @else

                        Date unavailable

                    @endif

                </p>

                <hr>

                <!-- Open Journal Details -->
                <a
                    href="{{ route('admin.journals.show', ['id' => $journal->id]) }}"
                    class="btn btn-outline-primary">

                    Open Journal Details

                </a>

            </div>

        @else

            <div class="alert alert-warning">
                The related journal is currently unavailable.
            </div>

        @endif

    </div>


    <!-- Delete Reply Section -->
    <div class="delete-section">

        <h5 class="mb-3">
            Delete Reply
        </h5>

        <p class="text-muted mb-3">
            Permanently remove this reply
            from the SafeSpace database.

            This action cannot be undone.
        </p>

        <!-- Delete Reply Form -->
        <form
            method="POST"
            action="{{ route('admin.replies.destroy', ['id' => $reply->id]) }}"
            onsubmit="return confirm('WARNING: This will permanently delete Reply #{{ $reply->id }}. Are you sure you want to continue?');"
        >

            @csrf
            @method('DELETE')

            <button
                type="submit"
                class="btn btn-danger delete-button">

                Delete Reply

            </button>

        </form>

    </div>


    <!-- Privacy Note -->
    <div class="privacy-note">

        <strong>
            Administrative Review
        </strong>

        <p class="mb-0 mt-2">
            This page displays the selected journal reply
            for authorized administrative review.

            Deleting a reply permanently removes its content.
            Related reports may remain available for review,
            but their reference to this reply may be cleared.
        </p>

    </div>


    <!-- Back Button -->
    <div class="mt-4">

        <a
            href="{{ route('admin.replies.index') }}"
            class="btn-back">

            &larr; Back to Replies

        </a>

    </div>

</div>

@endsection
