
@extends('admin.layouts.app')

@section('title', 'Manage Tips & Articles')

@section('page-title', 'Manage Tips & Articles')

@push('styles')
<style>
    /* Statistics Cards */
    .tip-stat-card {
        background: #ffffff;
        border-radius: 12px;
        padding: 25px;
        border-left: 4px solid #5271a5;
        box-shadow: 0 3px 12px rgba(0,0,0,0.05);
        height: 100%;
    }

    .tip-stat-card h6 {
        color: #777;
        margin-bottom: 15px;
    }

    .tip-stat-card h2 {
        color: #344e7a;
        font-size: 36px;
        font-weight: bold;
        margin-bottom: 0;
    }

    /* Published Card */
    .stat-published {
        border-left-color: #198754;
    }

    .stat-published h2 {
        color: #198754;
    }

    /* Draft Card */
    .stat-draft {
        border-left-color: #ffc107;
    }

    .stat-draft h2 {
        color: #bd8c00;
    }

    /* Add Content Button */
    .btn-add-content {
        display: inline-block;
        background: #5271a5;
        color: #ffffff;
        padding: 11px 20px;
        border-radius: 8px;
        text-decoration: none;
        font-weight: 600;
        white-space: nowrap;
    }

    .btn-add-content:hover {
        background: #344e7a;
        color: #ffffff;
    }

    /* Search and Filter Section */
    .tip-filter-section {
        background: #f8fafd;
        border: 1px solid #e3eaf4;
        padding: 22px;
        border-radius: 12px;
        margin-bottom: 25px;
    }

    .tip-filter-title {
        color: #344e7a;
        font-weight: 600;
        margin-bottom: 18px;
    }

    .tip-filter-section .form-label {
        color: #344e7a;
        font-weight: 600;
        font-size: 14px;
    }

    .tip-filter-section .form-control,
    .tip-filter-section .form-select {
        border-radius: 8px;
        padding: 10px 12px;
    }

    .btn-search {
        background: #5271a5;
        color: #ffffff;
        border: none;
        padding: 10px 22px;
        border-radius: 8px;
        font-weight: 600;
    }

    .btn-search:hover {
        background: #344e7a;
        color: #ffffff;
    }

    .btn-clear {
        border-radius: 8px;
        padding: 10px 22px;
        font-weight: 600;
    }

    /* Content Table */
    .tip-table th,
    .tip-table td {
        vertical-align: middle;
        padding: 14px 12px;
    }

    .tip-title {
        color: #344e7a;
        font-weight: 600;
        overflow-wrap: anywhere;
    }

    .tip-preview {
        color: #555;
        white-space: pre-wrap;
        overflow-wrap: anywhere;
    }

    .tip-badge {
        font-size: 12px;
        padding: 7px 11px;
    }

    /* Empty State */
    .empty-tips {
        text-align: center;
        padding: 40px 15px;
        color: #777;
    }

    /* Information Note */
    .tip-note {
        background: #eef4fb;
        padding: 18px;
        border-radius: 10px;
        color: #52627a;
        margin-top: 25px;
    }
</style>
@endpush

@section('content')

<!-- Content Statistics -->
<div class="row g-4 mb-4">

    <!-- Total Content -->
    <div class="col-md-4">

        <div class="tip-stat-card">

            <h6>
                Total Content
            </h6>

            <h2>
                {{ number_format($totalContents) }}
            </h2>

        </div>

    </div>


    <!-- Published Content -->
    <div class="col-md-4">

        <div class="tip-stat-card stat-published">

            <h6>
                Published Content
            </h6>

            <h2>
                {{ number_format($publishedContents) }}
            </h2>

        </div>

    </div>


    <!-- Draft Content -->
    <div class="col-md-4">

        <div class="tip-stat-card stat-draft">

            <h6>
                Draft Content
            </h6>

            <h2>
                {{ number_format($draftContents) }}
            </h2>

        </div>

    </div>

</div>


<!-- Main Content List -->
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
                Emotional Support Content
            </h5>

            <p class="text-muted mb-0">
                Search, filter and manage emotional
                support tips and articles for SafeSpace users.
            </p>

        </div>

        <!-- Add Content Button -->
        <a
            href="{{ route('admin.tips.create') }}"
            class="btn-add-content"
        >
            + Add New Content
        </a>

    </div>


    <!-- Search and Filter Section -->
    <div class="tip-filter-section">

        <h6 class="tip-filter-title">
            Search &amp; Filter Content
        </h6>

        <form
            method="GET"
            action="{{ route('admin.tips.index') }}"
        >

            <div class="row g-3">

                <!-- Search Input -->
                <div class="col-md-6">

                    <label
                        for="search"
                        class="form-label"
                    >
                        Search Title or Category
                    </label>

                    <input
                        type="text"
                        name="search"
                        id="search"
                        class="form-control"
                        placeholder="Enter title or category..."
                        value="{{ $search }}"
                        maxlength="100"
                    >

                </div>


                <!-- Type Filter -->
                <div class="col-md-3">

                    <label
                        for="type"
                        class="form-label"
                    >
                        Content Type
                    </label>

                    <select
                        name="type"
                        id="type"
                        class="form-select"
                    >

                        <option
                            value=""
                            {{ $type === '' ? 'selected' : '' }}
                        >
                            All Types
                        </option>

                        <option
                            value="tip"
                            {{ $type === 'tip' ? 'selected' : '' }}
                        >
                            Tip
                        </option>

                        <option
                            value="article"
                            {{ $type === 'article' ? 'selected' : '' }}
                        >
                            Article
                        </option>

                    </select>

                </div>


                <!-- Publication Status Filter -->
                <div class="col-md-3">

                    <label
                        for="status"
                        class="form-label"
                    >
                        Publication Status
                    </label>

                    <select
                        name="status"
                        id="status"
                        class="form-select"
                    >

                        <option
                            value=""
                            {{ $status === '' ? 'selected' : '' }}
                        >
                            All Statuses
                        </option>

                        <option
                            value="1"
                            {{ $status === '1' ? 'selected' : '' }}
                        >
                            Published
                        </option>

                        <option
                            value="0"
                            {{ $status === '0' ? 'selected' : '' }}
                        >
                            Draft
                        </option>

                    </select>

                </div>

            </div>


            <!-- Filter Action Buttons -->
            <div class="d-flex flex-wrap gap-2 mt-3">

                <!-- Apply Filters -->
                <button
                    type="submit"
                    class="btn-search"
                >
                    Search &amp; Filter
                </button>

                <!-- Clear Filters -->
                <a
                    href="{{ route('admin.tips.index') }}"
                    class="btn btn-outline-secondary btn-clear"
                >
                    Clear Filters
                </a>

            </div>

        </form>

    </div>


    <!-- Active Filters Information -->
    @if ($search !== '' || $type !== '' || $status !== '')

        <div class="alert alert-info">

            <strong>
                Active Filters:
            </strong>

            @if ($search !== '')

                <span class="ms-2">
                    Search:
                    <strong>{{ $search }}</strong>
                </span>

            @endif

            @if ($type !== '')

                <span class="ms-2">
                    Type:
                    <strong>
                        {{ ucfirst($type) }}
                    </strong>
                </span>

            @endif

            @if ($status !== '')

                <span class="ms-2">
                    Status:
                    <strong>
                        {{ $status === '1' ? 'Published' : 'Draft' }}
                    </strong>
                </span>

            @endif

            <div class="mt-2">
                Found
                <strong>{{ $contents->total() }}</strong>
                matching content(s).
            </div>

        </div>

    @endif


    <!-- Total Results -->
    <div class="mb-3">

        <span class="badge bg-primary">
            Results: {{ $contents->total() }}
        </span>

    </div>


    <!-- Tips and Articles Table -->
    <div class="table-responsive">

        <table class="table table-hover tip-table">

            <thead>

                <tr>
                    <th>ID</th>
                    <th>Title</th>
                    <th>Content Preview</th>
                    <th>Category</th>
                    <th>Type</th>
                    <th>Status</th>
                    <th>Created By</th>
                    <th>Created Date</th>
                    <th>Action</th>
                </tr>

            </thead>

            <tbody>

                @forelse ($contents as $item)

                    <tr>

                        <!-- Content ID -->
                        <td>

                            <strong>
                                #{{ $item->id }}
                            </strong>

                        </td>


                        <!-- Title -->
                        <td style="min-width: 170px;">

                            <span class="tip-title">
                                {{ $item->title }}
                            </span>

                        </td>


                        <!-- Content Preview -->
                        <td style="min-width: 240px;">

                            <div class="tip-preview">{{ \Illuminate\Support\Str::limit($item->content, 120) }}</div>

                        </td>


                        <!-- Category -->
                        <td>

                            {{ $item->category ?: '-' }}

                        </td>


                        <!-- Content Type -->
                        <td>

                            @if ($item->type === 'tip')

                                <span class="badge bg-primary tip-badge">
                                    Tip
                                </span>

                            @elseif ($item->type === 'article')

                                <span class="badge bg-info text-dark tip-badge">
                                    Article
                                </span>

                            @else

                                <span class="badge bg-secondary tip-badge">
                                    Unknown
                                </span>

                            @endif

                        </td>


                        <!-- Publication Status -->
                        <td>

                            @if ((int) $item->is_published === 1)

                                <span class="badge bg-success tip-badge">
                                    Published
                                </span>

                            @else

                                <span class="badge bg-warning text-dark tip-badge">
                                    Draft
                                </span>

                            @endif

                        </td>


                        <!-- Created By -->
                        <td>

                            @if ($item->admin_name)

                                {{ $item->admin_name }}

                            @else

                                <span class="text-muted">
                                    Unavailable
                                </span>

                            @endif

                        </td>


                        <!-- Created Date -->
                        <td>

                            @if ($item->created_at)

                                {{ \Carbon\Carbon::parse($item->created_at)->format('d M Y, h:i A') }}

                            @else

                                -

                            @endif

                        </td>


                        <!-- View Details -->
                        <td>

                            <a
                                href="{{ route('admin.tips.show', ['id' => $item->id]) }}"
                                class="btn btn-sm btn-primary text-nowrap"
                            >
                                View Details
                            </a>

                        </td>

                    </tr>

                @empty

                    <tr>

                        <td colspan="9">

                            <div class="empty-tips">

                                @if ($search !== '' || $type !== '' || $status !== '')

                                    <h5 class="mb-2">
                                        No Matching Content
                                    </h5>

                                    <p class="mb-3">
                                        No tips or articles match
                                        your selected filters.

                                        Try different search keywords
                                        or clear all filters.
                                    </p>

                                    <a
                                        href="{{ route('admin.tips.index') }}"
                                        class="btn btn-outline-secondary"
                                    >
                                        Clear Filters
                                    </a>

                                @else

                                    <h5 class="mb-2">
                                        No Tips or Articles Found
                                    </h5>

                                    <p class="mb-3">
                                        No emotional support content
                                        has been created yet.
                                    </p>

                                    <a
                                        href="{{ route('admin.tips.create') }}"
                                        class="btn-add-content"
                                    >
                                        Create First Content
                                    </a>

                                @endif

                            </div>

                        </td>

                    </tr>

                @endforelse

            </tbody>

        </table>

    </div>


    <!-- Pagination -->
    @if ($contents->hasPages())

        <div class="mt-4">

            {{ $contents->links('pagination::bootstrap-5') }}

        </div>

    @endif

</div>


<!-- Information Note -->
<div class="tip-note">

    <strong>
        Tips &amp; Articles Management
    </strong>

    <p class="mb-0 mt-2">
        Use Search &amp; Filter to find content
        by title, category, content type or
        publication status.

        Select View Details to read, edit
        or delete existing content.

        Only published content should be
        returned to regular users through
        the future SafeSpace Mobile API.
    </p>

</div>

@endsection
