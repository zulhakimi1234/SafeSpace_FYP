
@extends('admin.layouts.app')

@section('title', 'Journal Details')

@section('page-title', 'Journal Details')

@push('styles')
<style>
    .journal-header {
        background: #f0f4fa;
        padding: 25px;
        border-radius: 12px;
        margin-bottom: 25px;
    }

    .journal-heading {
        color: #344e7a;
        font-weight: bold;
        overflow-wrap: anywhere;
    }

    .journal-label {
        color: #777;
        font-weight: 500;
    }

    .journal-value {
        color: #344e7a;
        font-weight: 600;
    }

    .journal-info-row {
        padding: 15px 0;
        border-bottom: 1px solid #e9ecef;
    }

    .journal-body {
        background: #fafbfd;
        padding: 25px;
        border: 1px solid #e6ebf2;
        border-radius: 12px;
        white-space: pre-wrap;
        overflow-wrap: anywhere;
        line-height: 1.9;
        color: #333;
    }

    .moderation-section {
        margin-top: 30px;
        padding: 25px;
        background: #f8fafd;
        border: 1px solid #e3eaf4;
        border-radius: 12px;
    }

    .delete-section {
        margin-top: 25px;
        padding: 25px;
        border: 1px solid #f1c5c5;
        background: #fffafa;
        border-radius: 12px;
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

    .action-button {
        padding: 10px 20px;
        border-radius: 8px;
        font-weight: 600;
    }
</style>
@endpush

@section('content')

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

    <!-- Journal Header -->
    <div class="journal-header">

        <h4 class="journal-heading mb-2">
            {{ $journal->title ?: 'Untitled Journal' }}
        </h4>

        <p class="text-muted mb-0">
            Anonymous Community Journal
        </p>

    </div>

    <!-- Journal Information -->
    <h5 class="mb-3">
        Journal Information
    </h5>

    <!-- Journal ID -->
    <div class="row journal-info-row">

        <div class="col-md-4 journal-label">
            Journal ID
        </div>

        <div class="col-md-8 journal-value">
            {{ $journal->id }}
        </div>

    </div>

    <!-- Moderation Status -->
    <div class="row journal-info-row">

        <div class="col-md-4 journal-label">
            Moderation Status
        </div>

        <div class="col-md-8">

            @if ($journal->moderation_status === 'normal')

                <span class="badge bg-success fs-6">
                    Normal
                </span>

            @elseif ($journal->moderation_status === 'hidden')

                <span class="badge bg-warning text-dark fs-6">
                    Hidden
                </span>

            @else

                <span class="badge bg-secondary fs-6">
                    Unknown
                </span>

            @endif

        </div>

    </div>

    <!-- Date Posted -->
    <div class="row journal-info-row">

        <div class="col-md-4 journal-label">
            Date Posted
        </div>

        <div class="col-md-8 journal-value">

            @if ($journal->created_at)

                {{ \Carbon\Carbon::parse($journal->created_at)->format('d M Y, h:i A') }}

            @else

                -

            @endif

        </div>

    </div>

    <!-- Last Updated -->
    <div class="row journal-info-row">

        <div class="col-md-4 journal-label">
            Last Updated
        </div>

        <div class="col-md-8 journal-value">

            @if ($journal->updated_at)

                {{ \Carbon\Carbon::parse($journal->updated_at)->format('d M Y, h:i A') }}

            @else

                -

            @endif

        </div>

    </div>

    <!-- Journal Content -->
    <div class="mt-4">

        <h5 class="mb-3">
            Journal Content
        </h5>

        <div class="journal-body">{{ $journal->content ?? 'No content available.' }}</div>

    </div>

    <!-- Journal Moderation Section -->
    <div class="moderation-section">

        <h5 class="mb-3">
            Journal Moderation
        </h5>

        @if ($journal->moderation_status === 'normal')

            <p class="text-muted">
                This journal is currently not hidden
                by moderation.

                You can hide this journal from the
                community without deleting it.
            </p>

            <!-- Hide Journal Form -->
            <form
                method="POST"
                action="{{ route('admin.journals.updateModerationStatus', ['id' => $journal->id]) }}"
                onsubmit="return confirm('Are you sure you want to hide this journal?');"
            >

                @csrf
                @method('PATCH')

                <input
                    type="hidden"
                    name="moderation_status"
                    value="hidden"
                >

                <button
                    type="submit"
                    class="btn btn-warning action-button">

                    Hide Journal

                </button>

            </form>

        @elseif ($journal->moderation_status === 'hidden')

            <p class="text-muted">
                This journal is currently hidden
                by moderation.

                You can remove this moderation
                restriction without changing
                the journal's privacy settings.
            </p>

            <!-- Unhide Journal Form -->
            <form
                method="POST"
                action="{{ route('admin.journals.updateModerationStatus', ['id' => $journal->id]) }}"
                onsubmit="return confirm('Are you sure you want to unhide this journal?');"
            >

                @csrf
                @method('PATCH')

                <input
                    type="hidden"
                    name="moderation_status"
                    value="normal"
                >

                <button
                    type="submit"
                    class="btn btn-success action-button">

                    Unhide Journal

                </button>

            </form>

        @else

            <div class="alert alert-warning mb-0">
                Unknown moderation status.
                Moderation actions are unavailable.
            </div>

        @endif

    </div>

    <!-- Delete Journal Section -->
    <div class="delete-section">

        <h5 class="text-danger mb-2">
            Delete Journal
        </h5>

        <p class="text-muted">
            Permanently remove this journal
            from the SafeSpace database.

            This action cannot be undone.
        </p>

        <form
            method="POST"
            action="{{ route('admin.journals.destroy', ['id' => $journal->id]) }}"
            onsubmit="return confirm('WARNING: This will permanently delete this journal. Are you sure you want to continue?');"
        >

            @csrf
            @method('DELETE')

            <button
                type="submit"
                class="btn btn-danger action-button">

                Delete Journal

            </button>

        </form>

    </div>

    <!-- Back Button -->
    <div class="mt-4">

        <a
            href="{{ route('admin.journals.index') }}"
            class="btn-back">

            &larr; Back to Journals

        </a>

    </div>

</div>

@endsection
