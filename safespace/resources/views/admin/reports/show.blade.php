
@extends('admin.layouts.app')

@section('title', 'Report Details')

@section('page-title', 'Report Details')

@push('styles')
<style>
    .report-header {
        background: #f0f4fa;
        padding: 25px;
        border-radius: 12px;
        margin-bottom: 25px;
    }

    .report-heading {
        color: #344e7a;
        font-weight: bold;
    }

    .report-info-row {
        padding: 17px 0;
        border-bottom: 1px solid #e9ecef;
    }

    .report-label {
        color: #777;
        font-weight: 500;
    }

    .report-value {
        color: #344e7a;
        font-weight: 600;
        overflow-wrap: anywhere;
    }

    .report-section {
        margin-top: 28px;
    }

    .report-section h5 {
        color: #344e7a;
        font-weight: 600;
        margin-bottom: 15px;
    }

    .report-text-box {
        background: #fafbfd;
        border: 1px solid #e6ebf2;
        border-radius: 12px;
        padding: 22px;
        color: #333;
        line-height: 1.8;
        white-space: pre-wrap;
        overflow-wrap: anywhere;
    }

    .target-content-box {
        background: #f8fafd;
        border: 1px solid #e3eaf4;
        border-radius: 12px;
        padding: 25px;
    }

    .target-title {
        color: #344e7a;
        font-weight: 600;
        overflow-wrap: anywhere;
    }

    .target-body {
        white-space: pre-wrap;
        overflow-wrap: anywhere;
        line-height: 1.8;
        color: #444;
    }

    .missing-target {
        border: 1px solid #f1d58b;
        background: #fff9e9;
        padding: 20px;
        border-radius: 10px;
        color: #7a6100;
    }

    .management-section {
        margin-top: 30px;
        padding: 25px;
        background: #f8fafd;
        border: 1px solid #dce6f3;
        border-radius: 12px;
    }

    .management-section h5 {
        color: #344e7a;
        font-weight: 600;
    }

    .btn-save {
        background: #5271a5;
        color: white;
        padding: 10px 22px;
        border: none;
        border-radius: 8px;
        font-weight: 600;
    }

    .btn-save:hover {
        background: #344e7a;
        color: white;
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

    .privacy-note {
        background: #eef4fb;
        border-radius: 10px;
        padding: 18px;
        color: #52627a;
        margin-top: 25px;
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

            <strong>
                Please check the following:
            </strong>

            <ul class="mb-0 mt-2">

                @foreach ($errors->all() as $error)

                    <li>{{ $error }}</li>

                @endforeach

            </ul>

        </div>

    @endif


    <!-- Report Header -->
    <div class="report-header">

        <div class="d-flex justify-content-between
                    align-items-center flex-wrap gap-3">

            <div>

                <h4 class="report-heading mb-2">
                    Report #{{ $report->id }}
                </h4>

                <p class="text-muted mb-0">
                    User Submitted Report
                </p>

            </div>

            <!-- Report Status -->
            <div>

                @if ($report->status === 'pending')

                    <span class="badge bg-warning text-dark fs-6">
                        Pending
                    </span>

                @elseif ($report->status === 'reviewed')

                    <span class="badge bg-info text-dark fs-6">
                        Reviewed
                    </span>

                @elseif ($report->status === 'resolved')

                    <span class="badge bg-success fs-6">
                        Resolved
                    </span>

                @else

                    <span class="badge bg-secondary fs-6">
                        Unknown
                    </span>

                @endif

            </div>

        </div>

    </div>


    <!-- Report Information -->
    <h5 class="mb-3">
        Report Information
    </h5>

    <!-- Report ID -->
    <div class="row report-info-row">

        <div class="col-md-4 report-label">
            Report ID
        </div>

        <div class="col-md-8 report-value">
            #{{ $report->id }}
        </div>

    </div>

    <!-- Reported By -->
    <div class="row report-info-row">

        <div class="col-md-4 report-label">
            Reported By
        </div>

        <div class="col-md-8 report-value">

            @if ($report->reporter_user_id !== null)

                User #{{ $report->reporter_user_id }}

            @else

                Unavailable

            @endif

        </div>

    </div>

    <!-- Report Type -->
    <div class="row report-info-row">

        <div class="col-md-4 report-label">
            Report Type
        </div>

        <div class="col-md-8">

            @if ($report->target_type === 'journal')

                <span class="badge bg-primary fs-6">
                    Journal
                </span>

            @elseif ($report->target_type === 'reply')

                <span class="badge bg-secondary fs-6">
                    Reply
                </span>

            @else

                <span class="badge bg-dark fs-6">
                    Unknown
                </span>

            @endif

        </div>

    </div>

    <!-- Reported Target -->
    <div class="row report-info-row">

        <div class="col-md-4 report-label">
            Reported Target
        </div>

        <div class="col-md-8 report-value">

            @if ($report->target_type === 'journal')

                @if ($report->journal_id !== null)

                    Journal #{{ $report->journal_id }}

                @else

                    Deleted Journal

                @endif

            @elseif ($report->target_type === 'reply')

                @if ($report->reply_id !== null)

                    Reply #{{ $report->reply_id }}

                @else

                    Deleted Reply

                @endif

            @else

                -

            @endif

        </div>

    </div>

    <!-- Report Reason -->
    <div class="row report-info-row">

        <div class="col-md-4 report-label">
            Report Reason
        </div>

        <div class="col-md-8 report-value">
            {{ $report->reason }}
        </div>

    </div>

    <!-- Current Status -->
    <div class="row report-info-row">

        <div class="col-md-4 report-label">
            Current Status
        </div>

        <div class="col-md-8">

            @if ($report->status === 'pending')

                <span class="badge bg-warning text-dark">
                    Pending
                </span>

            @elseif ($report->status === 'reviewed')

                <span class="badge bg-info text-dark">
                    Reviewed
                </span>

            @elseif ($report->status === 'resolved')

                <span class="badge bg-success">
                    Resolved
                </span>

            @else

                <span class="badge bg-secondary">
                    Unknown
                </span>

            @endif

        </div>

    </div>

    <!-- Reported Date -->
    <div class="row report-info-row">

        <div class="col-md-4 report-label">
            Reported Date
        </div>

        <div class="col-md-8 report-value">

            @if ($report->created_at)

                {{ \Carbon\Carbon::parse($report->created_at)->format('d M Y, h:i A') }}

            @else

                -

            @endif

        </div>

    </div>

    <!-- Last Updated -->
    <div class="row report-info-row">

        <div class="col-md-4 report-label">
            Last Updated
        </div>

        <div class="col-md-8 report-value">

            @if ($report->updated_at)

                {{ \Carbon\Carbon::parse($report->updated_at)->format('d M Y, h:i A') }}

            @else

                -

            @endif

        </div>

    </div>

    <!-- Reviewed Date -->
    <div class="row report-info-row">

        <div class="col-md-4 report-label">
            Reviewed Date
        </div>

        <div class="col-md-8 report-value">

            @if ($report->reviewed_at)

                {{ \Carbon\Carbon::parse($report->reviewed_at)->format('d M Y, h:i A') }}

            @else

                Not reviewed yet

            @endif

        </div>

    </div>


    <!-- Report Description -->
    <div class="report-section">

        <h5>
            Report Description
        </h5>

        <div class="report-text-box">{{ $report->description ?: 'No additional description provided.' }}</div>

    </div>


    <!-- Reported Content -->
    <div class="report-section">

        <h5>
            Reported Content
        </h5>

        @if ($report->target_type === 'journal')

            <!-- Reported Journal -->
            @if ($targetJournal !== null)

                <div class="target-content-box">

                    <div class="d-flex justify-content-between
                                align-items-center flex-wrap gap-2 mb-3">

                        <strong class="target-title">
                            Journal #{{ $targetJournal->id }}
                        </strong>

                        @if ($targetJournal->moderation_status === 'normal')

                            <span class="badge bg-success">
                                Normal
                            </span>

                        @elseif ($targetJournal->moderation_status === 'hidden')

                            <span class="badge bg-warning text-dark">
                                Hidden
                            </span>

                        @endif

                    </div>

                    <h5 class="target-title">
                        {{ $targetJournal->title ?: 'Untitled Journal' }}
                    </h5>

                    <div class="target-body mt-3">{{ $targetJournal->content }}</div>

                    <hr>

                    <a
                        href="{{ route('admin.journals.show', ['id' => $targetJournal->id]) }}"
                        class="btn btn-outline-primary btn-sm">

                        Open Journal Details

                    </a>

                </div>

            @else

                <div class="missing-target">

                    <strong>
                        Journal No Longer Available
                    </strong>

                    <p class="mb-0 mt-2">
                        The reported journal may
                        have been deleted.

                        The report record is still
                        available for review.
                    </p>

                </div>

            @endif


        @elseif ($report->target_type === 'reply')

            <!-- Reported Reply -->
            @if ($targetReply !== null)

                <div class="target-content-box">

                    <strong class="target-title">
                        Reply #{{ $targetReply->id }}
                    </strong>

                    <p class="text-muted mt-2 mb-3">
                        Posted under Journal
                        #{{ $targetReply->journal_id }}
                    </p>

                    <div class="target-body">{{ $targetReply->content }}</div>

                    <hr>

                    <p class="text-muted mb-0">

                        @if ($targetReply->created_at)

                            Posted on
                            {{ \Carbon\Carbon::parse($targetReply->created_at)->format('d M Y, h:i A') }}

                        @else

                            Date unavailable

                        @endif

                    </p>

                </div>

            @else

                <div class="missing-target">

                    <strong>
                        Reply No Longer Available
                    </strong>

                    <p class="mb-0 mt-2">
                        The reported reply may
                        have been deleted.

                        The report record is still
                        available for review.
                    </p>

                </div>

            @endif

        @else

            <div class="alert alert-warning">
                Unknown reported content type.
            </div>

        @endif

    </div>


    <!-- Report Management -->
    <div class="management-section">

        <h5 class="mb-3">
            Report Management
        </h5>

        <p class="text-muted">
            Update the report status and
            record your moderation notes below.
        </p>

        <form
            method="POST"
            action="{{ route('admin.reports.updateStatus', ['id' => $report->id]) }}"
            onsubmit="return confirm('Are you sure you want to save these report changes?');"
        >

            @csrf
            @method('PATCH')

            <!-- Report Status -->
            <div class="mb-4">

                <label
                    for="status"
                    class="form-label fw-semibold">

                    Report Status

                </label>

                <select
                    name="status"
                    id="status"
                    class="form-select @error('status') is-invalid @enderror"
                    required
                >

                    <option
                        value="pending"
                        {{ old('status', $report->status) === 'pending' ? 'selected' : '' }}
                    >
                        Pending
                    </option>

                    <option
                        value="reviewed"
                        {{ old('status', $report->status) === 'reviewed' ? 'selected' : '' }}
                    >
                        Reviewed
                    </option>

                    <option
                        value="resolved"
                        {{ old('status', $report->status) === 'resolved' ? 'selected' : '' }}
                    >
                        Resolved
                    </option>

                </select>

                @error('status')

                    <div class="invalid-feedback">
                        {{ $message }}
                    </div>

                @enderror

            </div>

            <!-- Admin Notes -->
            <div class="mb-4">

                <label
                    for="admin_notes"
                    class="form-label fw-semibold">

                    Admin Notes

                </label>

                <textarea
                    name="admin_notes"
                    id="admin_notes"
                    rows="5"
                    maxlength="5000"
                    class="form-control @error('admin_notes') is-invalid @enderror"
                    placeholder="Enter your review findings or moderation actions..."
                >{{ old('admin_notes', $report->admin_notes) }}</textarea>

                <div class="form-text">
                    Maximum 5,000 characters.
                    These notes are for admin use only.
                </div>

                @error('admin_notes')

                    <div class="invalid-feedback">
                        {{ $message }}
                    </div>

                @enderror

            </div>

            <!-- Save Changes Button -->
            <button
                type="submit"
                class="btn-save">

                Save Changes

            </button>

        </form>

    </div>


    <!-- Privacy Note -->
    <div class="privacy-note">

        <strong>
            Administrative Review
        </strong>

        <p class="mb-0 mt-2">
            Report details and moderation notes
            are intended for authorized admin use only.

            Resolving a report does not automatically
            remove or hide the reported content.
        </p>

    </div>


    <!-- Back Button -->
    <div class="mt-4">

        <a
            href="{{ route('admin.reports.index') }}"
            class="btn-back">

            &larr; Back to Reports

        </a>

    </div>

</div>

@endsection
