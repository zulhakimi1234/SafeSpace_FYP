
@extends('admin.layouts.app')

@section('title', 'Content Details')

@section('page-title', 'Tip / Article Details')

@push('styles')
<style>
    /* Content Header */
    .content-header {
        background: #f0f4fa;
        padding: 25px;
        border-radius: 12px;
        margin-bottom: 25px;
    }

    .content-heading {
        color: #344e7a;
        font-weight: bold;
        overflow-wrap: anywhere;
    }

    /* Content Information */
    .content-info-row {
        padding: 18px 0;
        border-bottom: 1px solid #e9ecef;
    }

    .content-info-label {
        color: #777;
        font-weight: 500;
    }

    .content-info-value {
        color: #344e7a;
        font-weight: 600;
        overflow-wrap: anywhere;
    }

    /* Full Content */
    .content-section {
        margin-top: 30px;
    }

    .content-section h5 {
        color: #344e7a;
        font-weight: 600;
        margin-bottom: 15px;
    }

    .content-body {
        background: #fafbfd;
        border: 1px solid #e6ebf2;
        border-radius: 12px;
        padding: 25px;
        white-space: pre-wrap;
        overflow-wrap: anywhere;
        line-height: 1.9;
        color: #333;
    }

    /* Publication Note */
    .publication-note {
        background: #eef4fb;
        border-radius: 10px;
        padding: 20px;
        color: #52627a;
        margin-top: 30px;
    }

    /* Delete Section */
    .delete-section {
        margin-top: 30px;
        background: #fffafa;
        border: 1px solid #f1c5c5;
        border-radius: 12px;
        padding: 25px;
    }

    .delete-section h5 {
        color: #dc3545;
        font-weight: 600;
    }

    .delete-button {
        border-radius: 8px;
        padding: 10px 20px;
        font-weight: 600;
    }

    /* Action Buttons */
    .content-actions {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        margin-top: 30px;
    }

    .btn-edit {
        background: #5271a5;
        color: white;
        padding: 10px 20px;
        border-radius: 8px;
        text-decoration: none;
        font-weight: 600;
        display: inline-block;
    }

    .btn-edit:hover {
        background: #344e7a;
        color: white;
    }

    .btn-back {
        padding: 10px 20px;
        border-radius: 8px;
        text-decoration: none;
        font-weight: 600;
        display: inline-block;
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


    <!-- Content Header -->
    <div class="content-header">

        <div class="d-flex justify-content-between
                    align-items-start flex-wrap gap-3">

            <div>

                <h4 class="content-heading mb-2">
                    {{ $content->title }}
                </h4>

                <p class="text-muted mb-0">
                    Emotional Support Content
                </p>

            </div>

            <!-- Type and Status Badges -->
            <div class="d-flex gap-2 flex-wrap">

                <!-- Content Type -->
                @if ($content->type === 'tip')

                    <span class="badge bg-primary fs-6">
                        Tip
                    </span>

                @elseif ($content->type === 'article')

                    <span class="badge bg-info text-dark fs-6">
                        Article
                    </span>

                @endif

                <!-- Publication Status -->
                @if ((int) $content->is_published === 1)

                    <span class="badge bg-success fs-6">
                        Published
                    </span>

                @else

                    <span class="badge bg-warning text-dark fs-6">
                        Draft
                    </span>

                @endif

            </div>

        </div>

    </div>


    <!-- Content Information -->
    <h5 class="mb-3">
        Content Information
    </h5>


    <!-- Content ID -->
    <div class="row content-info-row">

        <div class="col-md-4 content-info-label">
            Content ID
        </div>

        <div class="col-md-8 content-info-value">
            #{{ $content->id }}
        </div>

    </div>


    <!-- Title -->
    <div class="row content-info-row">

        <div class="col-md-4 content-info-label">
            Title
        </div>

        <div class="col-md-8 content-info-value">
            {{ $content->title }}
        </div>

    </div>


    <!-- Category -->
    <div class="row content-info-row">

        <div class="col-md-4 content-info-label">
            Category
        </div>

        <div class="col-md-8 content-info-value">
            {{ $content->category }}
        </div>

    </div>


    <!-- Content Type -->
    <div class="row content-info-row">

        <div class="col-md-4 content-info-label">
            Content Type
        </div>

        <div class="col-md-8">

            @if ($content->type === 'tip')

                <span class="badge bg-primary">
                    Tip
                </span>

            @elseif ($content->type === 'article')

                <span class="badge bg-info text-dark">
                    Article
                </span>

            @else

                <span class="badge bg-secondary">
                    Unknown
                </span>

            @endif

        </div>

    </div>


    <!-- Publication Status -->
    <div class="row content-info-row">

        <div class="col-md-4 content-info-label">
            Publication Status
        </div>

        <div class="col-md-8">

            @if ((int) $content->is_published === 1)

                <span class="badge bg-success">
                    Published
                </span>

            @else

                <span class="badge bg-warning text-dark">
                    Draft
                </span>

            @endif

        </div>

    </div>


    <!-- Created By -->
    <div class="row content-info-row">

        <div class="col-md-4 content-info-label">
            Created By
        </div>

        <div class="col-md-8 content-info-value">

            @if ($content->admin_name)

                {{ $content->admin_name }}

            @else

                Unavailable

            @endif

        </div>

    </div>


    <!-- Created Date -->
    <div class="row content-info-row">

        <div class="col-md-4 content-info-label">
            Created Date
        </div>

        <div class="col-md-8 content-info-value">

            @if ($content->created_at)

                {{ \Carbon\Carbon::parse($content->created_at)->format('d M Y, h:i A') }}

            @else

                -

            @endif

        </div>

    </div>


    <!-- Last Updated -->
    <div class="row content-info-row">

        <div class="col-md-4 content-info-label">
            Last Updated
        </div>

        <div class="col-md-8 content-info-value">

            @if ($content->updated_at)

                {{ \Carbon\Carbon::parse($content->updated_at)->format('d M Y, h:i A') }}

            @else

                -

            @endif

        </div>

    </div>


    <!-- Full Content -->
    <div class="content-section">

        <h5>
            Full Content
        </h5>

        <div class="content-body">{{ $content->content }}</div>

    </div>


    <!-- Publication Information -->
    <div class="publication-note">

        <strong>
            Publication Information
        </strong>

        @if ((int) $content->is_published === 1)

            <p class="mb-0 mt-2">
                This content is currently
                marked as Published.

                It can be displayed in
                the SafeSpace Mobile App
                once the Mobile API is implemented.
            </p>

        @else

            <p class="mb-0 mt-2">
                This content is currently
                saved as Draft.

                Draft content must remain
                unavailable to regular Mobile App users.
            </p>

        @endif

    </div>


    <!-- Delete Content Section -->
    <div class="delete-section">

        <h5 class="mb-3">
            Delete Content
        </h5>

        <p class="text-muted mb-3">
            Permanently remove this Tip or Article
            from the SafeSpace database.

            This action cannot be undone.
        </p>

        <!-- Delete Content Form -->
        <form
            method="POST"
            action="{{ route('admin.tips.destroy', ['id' => $content->id]) }}"
            onsubmit="return confirm('WARNING: This will permanently delete Content #{{ $content->id }}. Are you sure you want to continue?');"
        >

            @csrf
            @method('DELETE')

            <button
                type="submit"
                class="btn btn-danger delete-button">

                Delete Content

            </button>

        </form>

    </div>


    <!-- Action Buttons -->
    <div class="content-actions">

        <!-- Edit Content -->
        <a
            href="{{ route('admin.tips.edit', ['id' => $content->id]) }}"
            class="btn-edit">

            Edit Content

        </a>

        <!-- Back to List -->
        <a
            href="{{ route('admin.tips.index') }}"
            class="btn btn-outline-secondary btn-back">

            &larr; Back to Tips &amp; Articles

        </a>

    </div>

</div>

@endsection
