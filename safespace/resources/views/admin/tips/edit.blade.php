
@extends('admin.layouts.app')

@section('title', 'Edit Content')

@section('page-title', 'Edit Tip / Article')

@push('styles')
<style>
    .edit-content-card {
        background: #ffffff;
        border-radius: 12px;
        padding: 30px;
        box-shadow: 0 3px 12px rgba(0,0,0,0.05);
    }

    .form-heading {
        color: #344e7a;
        font-weight: 600;
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
        padding: 18px;
        border-radius: 10px;
        color: #52627a;
    }

    .btn-update {
        background: #5271a5;
        color: #ffffff;
        border: none;
        border-radius: 8px;
        padding: 11px 22px;
        font-weight: 600;
    }

    .btn-update:hover {
        background: #344e7a;
        color: #ffffff;
    }

    .btn-cancel {
        border-radius: 8px;
        padding: 11px 22px;
    }
</style>
@endpush

@section('content')

<div class="edit-content-card">

    <!-- Page Header -->
    <div class="mb-4">

        <h4 class="form-heading mb-2">
            Edit Content #{{ $content->id }}
        </h4>

        <p class="text-muted mb-0">
            Update an existing SafeSpace
            emotional support tip or article.
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

    <!-- Edit Content Form -->
    <form
        method="POST"
        action="{{ route('admin.tips.update', ['id' => $content->id]) }}"
        onsubmit="return confirm('Are you sure you want to update this content?');"
    >

        @csrf
        @method('PUT')

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
                value="{{ old('title', $content->title) }}"
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

        <!-- Category and Type -->
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
                    value="{{ old('category', $content->category) }}"
                    maxlength="100"
                    required
                >

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

                    <option
                        value="tip"
                        {{ old('type', $content->type) === 'tip' ? 'selected' : '' }}
                    >
                        Tip
                    </option>

                    <option
                        value="article"
                        {{ old('type', $content->type) === 'article' ? 'selected' : '' }}
                    >
                        Article
                    </option>

                </select>

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
                placeholder="Enter content..."
                maxlength="20000"
                required
            >{{ old('content', $content->content) }}</textarea>

            <div class="form-text">
                Maximum 20,000 characters.
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
                    {{ (string) old('is_published', $content->is_published) === '0' ? 'selected' : '' }}
                >
                    Draft
                </option>

                <option
                    value="1"
                    {{ (string) old('is_published', $content->is_published) === '1' ? 'selected' : '' }}
                >
                    Published
                </option>

            </select>

            @error('is_published')

                <div class="invalid-feedback">
                    {{ $message }}
                </div>

            @enderror

        </div>

        <!-- Publication Note -->
        <div class="publication-note mb-4">

            <strong>
                Publication Information
            </strong>

            <p class="mb-0 mt-2">
                Change the status to Published
                when the content is ready
                for SafeSpace users.

                Change it to Draft to keep
                the content unavailable
                through the future Mobile API.

                The original creator and
                creation date will remain unchanged.
            </p>

        </div>

        <!-- Action Buttons -->
        <div class="d-flex gap-2 flex-wrap">

            <!-- Update Button -->
            <button
                type="submit"
                class="btn-update">

                Update Content

            </button>

            <!-- Cancel Button -->
            <a
                href="{{ route('admin.tips.show', ['id' => $content->id]) }}"
                class="btn btn-outline-secondary btn-cancel">

                Cancel

            </a>

        </div>

    </form>

</div>

@endsection
