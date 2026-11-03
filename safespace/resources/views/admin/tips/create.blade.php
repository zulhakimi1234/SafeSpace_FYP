
@extends('admin.layouts.app')

@section('title', 'Add New Content')

@section('page-title', 'Add New Tip or Article')

@push('styles')
<style>
    .create-content-card {
        background: #ffffff;
        border-radius: 12px;
        padding: 30px;
        box-shadow: 0 3px 12px rgba(0,0,0,0.05);
    }

    .form-heading {
        color: #344e7a;
        font-weight: 600;
        margin-bottom: 8px;
    }

    .form-label {
        color: #344e7a;
        font-weight: 600;
    }

    .form-control,
    .form-select {
        border-radius: 8px;
        padding: 11px 13px;
    }

    .content-textarea {
        min-height: 260px;
        resize: vertical;
    }

    .publication-note {
        background: #eef4fb;
        border-radius: 10px;
        padding: 18px;
        color: #52627a;
    }

    .btn-save-content {
        background: #5271a5;
        color: white;
        border: none;
        border-radius: 8px;
        padding: 11px 22px;
        font-weight: 600;
    }

    .btn-save-content:hover {
        background: #344e7a;
        color: white;
    }

    .btn-cancel {
        border-radius: 8px;
        padding: 11px 22px;
    }
</style>
@endpush

@section('content')

<div class="create-content-card">

    <!-- Page Header -->
    <div class="mb-4">

        <h4 class="form-heading">
            Create New Content
        </h4>

        <p class="text-muted mb-0">
            Create an emotional support tip or
            article for SafeSpace users.
        </p>

    </div>

    <!-- Validation Errors -->
    @if ($errors->any())

        <div class="alert alert-danger">

            <strong>
                Please check your input:
            </strong>

            <ul class="mb-0 mt-2">

                @foreach ($errors->all() as $error)

                    <li>{{ $error }}</li>

                @endforeach

            </ul>

        </div>

    @endif

    <!-- Create Content Form -->
    <form
        method="POST"
        action="{{ route('admin.tips.store') }}"
    >

        @csrf

        <!-- Content Title -->
        <div class="mb-4">

            <label
                for="title"
                class="form-label">

                Content Title
                <span class="text-danger">*</span>

            </label>

            <input
                type="text"
                id="title"
                name="title"
                class="form-control @error('title') is-invalid @enderror"
                placeholder="Enter content title..."
                value="{{ old('title') }}"
                maxlength="200"
                required
            >

            <div class="form-text">
                Maximum 200 characters.
            </div>

            @error('title')
                <div class="invalid-feedback">
                    {{ $message }}
                </div>
            @enderror

        </div>


        <!-- Content Category and Type -->
        <div class="row g-3 mb-4">

            <!-- Category -->
            <div class="col-md-6">

                <label
                    for="category"
                    class="form-label">

                    Category
                    <span class="text-danger">*</span>

                </label>

                <input
                    type="text"
                    id="category"
                    name="category"
                    class="form-control @error('category') is-invalid @enderror"
                    placeholder="e.g. Stress Management"
                    value="{{ old('category') }}"
                    maxlength="100"
                    required
                >

                <div class="form-text">
                    Examples: Stress Management,
                    Self-Care, Motivation.
                </div>

                @error('category')
                    <div class="invalid-feedback">
                        {{ $message }}
                    </div>
                @enderror

            </div>


            <!-- Content Type -->
            <div class="col-md-6">

                <label
                    for="type"
                    class="form-label">

                    Content Type
                    <span class="text-danger">*</span>

                </label>

                <select
                    name="type"
                    id="type"
                    class="form-select @error('type') is-invalid @enderror"
                    required
                >

                    <option value="tip"
                        {{ old('type', 'tip') === 'tip' ? 'selected' : '' }}>
                        Tip
                    </option>

                    <option value="article"
                        {{ old('type') === 'article' ? 'selected' : '' }}>
                        Article
                    </option>

                </select>

                <div class="form-text">
                    Choose Tip or Article.
                </div>

                @error('type')
                    <div class="invalid-feedback">
                        {{ $message }}
                    </div>
                @enderror

            </div>

        </div>


        <!-- Content Body -->
        <div class="mb-4">

            <label
                for="content"
                class="form-label">

                Content
                <span class="text-danger">*</span>

            </label>

            <textarea
                name="content"
                id="content"
                class="form-control content-textarea @error('content') is-invalid @enderror"
                placeholder="Write your emotional support content here..."
                maxlength="20000"
                required
            >{{ old('content') }}</textarea>

            <div class="form-text">
                Maximum 20,000 characters.
                Plain text content only.
            </div>

            @error('content')
                <div class="invalid-feedback">
                    {{ $message }}
                </div>
            @enderror

        </div>


        <!-- Publication Status -->
        <div class="mb-4">

            <label
                for="is_published"
                class="form-label">

                Publication Status
                <span class="text-danger">*</span>

            </label>

            <select
                name="is_published"
                id="is_published"
                class="form-select @error('is_published') is-invalid @enderror"
                required
            >

                <option
                    value="0"
                    {{ old('is_published', '0') == '0' ? 'selected' : '' }}
                >
                    Draft
                </option>

                <option
                    value="1"
                    {{ old('is_published') == '1' ? 'selected' : '' }}
                >
                    Published
                </option>

            </select>

            <div class="form-text">
                Draft content will not be included
                in the public Mobile API.
            </div>

            @error('is_published')
                <div class="invalid-feedback">
                    {{ $message }}
                </div>
            @enderror

        </div>


        <!-- Publication Information -->
        <div class="publication-note mb-4">

            <strong>
                Publication Information
            </strong>

            <p class="mb-0 mt-2">
                Draft content is saved for
                administrative editing.

                Published content will be eligible
                for display in the SafeSpace
                Mobile App when the Mobile API
                is implemented.

                The currently logged-in admin
                will be recorded automatically
                as the content creator.
            </p>

        </div>


        <!-- Action Buttons -->
        <div class="d-flex flex-wrap gap-2">

            <!-- Save -->
            <button
                type="submit"
                class="btn-save-content"
            >
                Save Content
            </button>

            <!-- Cancel -->
            <a
                href="{{ route('admin.tips.index') }}"
                class="btn btn-outline-secondary btn-cancel"
            >
                Cancel
            </a>

        </div>

    </form>

</div>

@endsection
