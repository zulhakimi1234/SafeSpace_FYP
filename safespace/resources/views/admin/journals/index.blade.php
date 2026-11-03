
@extends('admin.layouts.app')

@section('title', 'Manage Journals')

@section('page-title', 'Manage Journal Posts')

@push('styles')
<style>
    .journal-title {
        font-weight: 600;
        color: #344e7a;
    }

    .journal-content {
        white-space: pre-wrap;
        overflow-wrap: anywhere;
    }

    .journal-status {
        font-size: 13px;
        padding: 7px 12px;
    }

    .filter-section {
        background: #f8fafd;
        border: 1px solid #e3eaf4;
        padding: 20px;
        border-radius: 10px;
        margin-bottom: 25px;
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

    <!-- Section Header -->
    <div class="d-flex justify-content-between
                align-items-center mb-4">

        <div>
            <h5 class="mb-1">
                All Journal Posts
            </h5>

            <p class="text-muted mb-0">
                Search and filter anonymous
                community journal posts.
            </p>
        </div>

        <span class="badge bg-primary">
            Total: {{ $journals->total() }}
        </span>

    </div>

    <!-- Search and Filter Section -->
    <div class="filter-section">

        <form method="GET"
              action="{{ route('admin.journals.index') }}">

            <div class="row g-3">

                <!-- Search Input -->
                <div class="col-md-5">

                    <label class="form-label">
                        Search Journal
                    </label>

                    <input
                        type="text"
                        name="search"
                        class="form-control"
                        placeholder="Search title or content..."
                        value="{{ $search }}"
                        maxlength="100"
                    >

                </div>

                <!-- Moderation Status Filter -->
                <div class="col-md-4">

                    <label class="form-label">
                        Moderation Status
                    </label>

                    <select
                        name="status"
                        class="form-select">

                        <option value="all"
                            {{ $status === 'all' ? 'selected' : '' }}>
                            All Journals
                        </option>

                        <option value="normal"
                            {{ $status === 'normal' ? 'selected' : '' }}>
                            Normal Journals
                        </option>

                        <option value="hidden"
                            {{ $status === 'hidden' ? 'selected' : '' }}>
                            Hidden Journals
                        </option>

                    </select>

                </div>

                <!-- Apply Filter Button -->
                <div class="col-md-2 d-flex align-items-end">

                    <button
                        type="submit"
                        class="btn btn-primary w-100">

                        Apply Filter

                    </button>

                </div>

                <!-- Clear Button -->
                <div class="col-md-1 d-flex align-items-end">

                    <a
                        href="{{ route('admin.journals.index') }}"
                        class="btn btn-outline-secondary w-100">

                        Clear

                    </a>

                </div>

            </div>

        </form>

    </div>

    <!-- Active Filters Information -->
    @if ($search !== '' || $status !== 'all')

        <div class="alert alert-info">

            <strong>Filtered Results</strong>

            <br>

            @if ($search !== '')

                Search:
                <strong>{{ $search }}</strong>

                <br>

            @endif

            @if ($status !== 'all')

                Moderation Status:
                <strong>{{ ucfirst($status) }}</strong>

                <br>

            @endif

            Found {{ $journals->total() }} journal(s).

        </div>

    @endif

    <!-- Journals Table -->
    <div class="table-responsive">

        <table class="table table-hover">

            <thead>
                <tr>
                    <th>ID</th>
                    <th>Title</th>
                    <th>Content Preview</th>
                    <th>Moderation Status</th>
                    <th>Date Posted</th>
                    <th>Action</th>
                </tr>
            </thead>

            <tbody>

                @forelse ($journals as $journal)

                    <tr>

                        <!-- Journal ID -->
                        <td>
                            {{ $journal->id }}
                        </td>

                        <!-- Journal Title -->
                        <td class="journal-title">
                            {{ $journal->title ?: 'Untitled Journal' }}
                        </td>

                        <!-- Content Preview -->
                        <td style="min-width: 220px;">

                            <div class="journal-content">

                                {{ \Illuminate\Support\Str::limit($journal->content ?? '', 100) }}

                            </div>

                        </td>

                        <!-- Moderation Status -->
                        <td>

                            @if ($journal->moderation_status === 'normal')

                                <span class="badge bg-success journal-status">
                                    Normal
                                </span>

                            @elseif ($journal->moderation_status === 'hidden')

                                <span class="badge bg-warning text-dark journal-status">
                                    Hidden
                                </span>

                            @else

                                <span class="badge bg-secondary journal-status">
                                    Unknown
                                </span>

                            @endif

                        </td>

                        <!-- Date Posted -->
                        <td>

                            @if ($journal->created_at)

                                {{ \Carbon\Carbon::parse($journal->created_at)->format('d M Y, h:i A') }}

                            @else

                                -

                            @endif

                        </td>

                        <!-- View Details -->
                        <td>

                            <a
                                href="{{ route('admin.journals.show', ['id' => $journal->id]) }}"
                                class="btn btn-sm btn-primary text-nowrap">

                                View Details

                            </a>

                        </td>

                    </tr>

                @empty

                    <tr>

                        <td colspan="6"
                            class="text-center text-muted py-4">

                            @if ($search !== '' || $status !== 'all')

                                No journal posts found
                                matching your filters.

                            @else

                                No journal posts found.

                            @endif

                        </td>

                    </tr>

                @endforelse

            </tbody>

        </table>

    </div>

    <!-- Pagination -->
    @if ($journals->hasPages())

        <div class="mt-4">

            {{ $journals->links('pagination::bootstrap-5') }}

        </div>

    @endif

</div>

@endsection
