
@extends('admin.layouts.app')

@section('title', 'Manage Reports')

@section('page-title', 'Manage Reports')

@push('styles')
<style>
    .report-stat-card {
        background: #ffffff;
        border-radius: 12px;
        padding: 22px;
        box-shadow: 0 3px 12px rgba(0,0,0,0.05);
        border-left: 4px solid #5271a5;
        height: 100%;
    }

    .report-stat-card h6 {
        color: #777;
        margin-bottom: 12px;
    }

    .report-stat-card h2 {
        color: #344e7a;
        font-size: 32px;
        font-weight: bold;
        margin-bottom: 0;
    }

    .stat-pending {
        border-left-color: #ffc107;
    }

    .stat-reviewed {
        border-left-color: #0dcaf0;
    }

    .stat-resolved {
        border-left-color: #198754;
    }

    .filter-section {
        background: #f8fafd;
        border: 1px solid #e3eaf4;
        padding: 22px;
        border-radius: 12px;
        margin-bottom: 25px;
    }

    .filter-section label {
        color: #344e7a;
        font-weight: 600;
    }

    .report-table th,
    .report-table td {
        vertical-align: middle;
        padding: 14px 12px;
    }

    .report-reason {
        color: #344e7a;
        font-weight: 600;
        overflow-wrap: anywhere;
    }

    .report-badge {
        font-size: 12px;
        padding: 7px 11px;
    }

    .empty-reports {
        padding: 35px 15px;
        text-align: center;
        color: #777;
    }

    .report-note {
        background: #eef4fb;
        border-radius: 10px;
        padding: 18px;
        color: #52627a;
    }
</style>
@endpush

@section('content')

<!-- Report Statistics -->
<div class="row g-4 mb-4">

    <!-- Total Reports -->
    <div class="col-md-6 col-xl-3">

        <div class="report-stat-card">

            <h6>Total Reports</h6>

            <h2>
                {{ number_format($totalReports) }}
            </h2>

        </div>

    </div>

    <!-- Pending Reports -->
    <div class="col-md-6 col-xl-3">

        <div class="report-stat-card stat-pending">

            <h6>Pending Reports</h6>

            <h2>
                {{ number_format($pendingReports) }}
            </h2>

        </div>

    </div>

    <!-- Reviewed Reports -->
    <div class="col-md-6 col-xl-3">

        <div class="report-stat-card stat-reviewed">

            <h6>Reviewed Reports</h6>

            <h2>
                {{ number_format($reviewedReports) }}
            </h2>

        </div>

    </div>

    <!-- Resolved Reports -->
    <div class="col-md-6 col-xl-3">

        <div class="report-stat-card stat-resolved">

            <h6>Resolved Reports</h6>

            <h2>
                {{ number_format($resolvedReports) }}
            </h2>

        </div>

    </div>

</div>


<!-- Reports List -->
<div class="content-card">

    <!-- Section Header -->
    <div class="d-flex justify-content-between
                align-items-center flex-wrap gap-3 mb-4">

        <div>

            <h5 class="mb-1">
                User Submitted Reports
            </h5>

            <p class="text-muted mb-0">
                Search and filter reports submitted
                through the SafeSpace Mobile App.
            </p>

        </div>

        <span class="badge bg-primary">
            Results: {{ $reports->total() }}
        </span>

    </div>


    <!-- Search and Filter Section -->
    <div class="filter-section">

        <form
            method="GET"
            action="{{ route('admin.reports.index') }}"
        >

            <div class="row g-3">

                <!-- Search Report -->
                <div class="col-md-12">

                    <label
                        for="search"
                        class="form-label">

                        Search Report

                    </label>

                    <input
                        type="text"
                        id="search"
                        name="search"
                        class="form-control"
                        placeholder="Search report reason or description..."
                        value="{{ $search }}"
                        maxlength="100"
                    >

                </div>

                <!-- Report Status Filter -->
                <div class="col-md-6">

                    <label
                        for="status"
                        class="form-label">

                        Report Status

                    </label>

                    <select
                        name="status"
                        id="status"
                        class="form-select"
                    >

                        <option
                            value="all"
                            {{ $status === 'all' ? 'selected' : '' }}
                        >
                            All Statuses
                        </option>

                        <option
                            value="pending"
                            {{ $status === 'pending' ? 'selected' : '' }}
                        >
                            Pending
                        </option>

                        <option
                            value="reviewed"
                            {{ $status === 'reviewed' ? 'selected' : '' }}
                        >
                            Reviewed
                        </option>

                        <option
                            value="resolved"
                            {{ $status === 'resolved' ? 'selected' : '' }}
                        >
                            Resolved
                        </option>

                    </select>

                </div>

                <!-- Report Type Filter -->
                <div class="col-md-6">

                    <label
                        for="type"
                        class="form-label">

                        Report Type

                    </label>

                    <select
                        name="type"
                        id="type"
                        class="form-select"
                    >

                        <option
                            value="all"
                            {{ $type === 'all' ? 'selected' : '' }}
                        >
                            All Types
                        </option>

                        <option
                            value="journal"
                            {{ $type === 'journal' ? 'selected' : '' }}
                        >
                            Journal
                        </option>

                        <option
                            value="reply"
                            {{ $type === 'reply' ? 'selected' : '' }}
                        >
                            Reply
                        </option>

                    </select>

                </div>

                <!-- Action Buttons -->
                <div class="col-12">

                    <div class="d-flex gap-2 flex-wrap">

                        <button
                            type="submit"
                            class="btn btn-primary">

                            Apply Filter

                        </button>

                        <a
                            href="{{ route('admin.reports.index') }}"
                            class="btn btn-outline-secondary">

                            Clear

                        </a>

                    </div>

                </div>

            </div>

        </form>

    </div>


    <!-- Validation Errors -->
    @if ($errors->any())

        <div class="alert alert-danger">

            {{ $errors->first() }}

        </div>

    @endif


    <!-- Active Filter Information -->
    @if (
        $search !== '' ||
        $status !== 'all' ||
        $type !== 'all'
    )

        <div class="alert alert-info">

            <strong>
                Filtered Results
            </strong>

            <br>

            @if ($search !== '')

                Search:
                <strong>{{ $search }}</strong>

                <br>

            @endif

            @if ($status !== 'all')

                Report Status:
                <strong>{{ ucfirst($status) }}</strong>

                <br>

            @endif

            @if ($type !== 'all')

                Report Type:
                <strong>{{ ucfirst($type) }}</strong>

                <br>

            @endif

            Found {{ $reports->total() }} report(s).

        </div>

    @endif


    <!-- Reports Table -->
    <div class="table-responsive">

        <table class="table table-hover report-table">

            <thead>

                <tr>
                    <th>Report ID</th>
                    <th>Reported By</th>
                    <th>Report Type</th>
                    <th>Target ID</th>
                    <th>Reason</th>
                    <th>Status</th>
                    <th>Reported Date</th>
                    <th>Action</th>
                </tr>

            </thead>

            <tbody>

                @forelse ($reports as $report)

                    <tr>

                        <!-- Report ID -->
                        <td>

                            <strong>
                                #{{ $report->id }}
                            </strong>

                        </td>


                        <!-- Reporter -->
                        <td>

                            @if ($report->reporter_user_id !== null)

                                User #{{ $report->reporter_user_id }}

                            @else

                                <span class="text-muted">
                                    Unavailable
                                </span>

                            @endif

                        </td>


                        <!-- Report Type -->
                        <td>

                            @if ($report->target_type === 'journal')

                                <span class="badge bg-primary report-badge">
                                    Journal
                                </span>

                            @elseif ($report->target_type === 'reply')

                                <span class="badge bg-secondary report-badge">
                                    Reply
                                </span>

                            @else

                                <span class="badge bg-dark report-badge">
                                    Unknown
                                </span>

                            @endif

                        </td>


                        <!-- Target ID -->
                        <td>

                            @if ($report->target_type === 'journal')

                                @if ($report->journal_id !== null)

                                    Journal #{{ $report->journal_id }}

                                @else

                                    <span class="text-muted">
                                        Deleted Journal
                                    </span>

                                @endif

                            @elseif ($report->target_type === 'reply')

                                @if ($report->reply_id !== null)

                                    Reply #{{ $report->reply_id }}

                                @else

                                    <span class="text-muted">
                                        Deleted Reply
                                    </span>

                                @endif

                            @else

                                -

                            @endif

                        </td>


                        <!-- Report Reason -->
                        <td>

                            <span class="report-reason">
                                {{ $report->reason }}
                            </span>

                        </td>


                        <!-- Report Status -->
                        <td>

                            @if ($report->status === 'pending')

                                <span class="badge bg-warning text-dark report-badge">
                                    Pending
                                </span>

                            @elseif ($report->status === 'reviewed')

                                <span class="badge bg-info text-dark report-badge">
                                    Reviewed
                                </span>

                            @elseif ($report->status === 'resolved')

                                <span class="badge bg-success report-badge">
                                    Resolved
                                </span>

                            @else

                                <span class="badge bg-secondary report-badge">
                                    Unknown
                                </span>

                            @endif

                        </td>


                        <!-- Reported Date -->
                        <td>

                            @if ($report->created_at)

                                {{ \Carbon\Carbon::parse($report->created_at)->format('d M Y, h:i A') }}

                            @else

                                -

                            @endif

                        </td>


                        <!-- View Details -->
                        <td>

                            <a
                                href="{{ route('admin.reports.show', ['id' => $report->id]) }}"
                                class="btn btn-sm btn-primary text-nowrap">

                                View Details

                            </a>

                        </td>

                    </tr>

                @empty

                    <!-- Empty State -->
                    <tr>

                        <td colspan="8">

                            <div class="empty-reports">

                                @if (
                                    $search !== '' ||
                                    $status !== 'all' ||
                                    $type !== 'all'
                                )

                                    <h5 class="mb-2">
                                        No Matching Reports
                                    </h5>

                                    <p class="mb-0">
                                        No reports match your current
                                        search or filter selections.

                                        Try changing the filters
                                        or click Clear.
                                    </p>

                                @else

                                    <h5 class="mb-2">
                                        No Reports Found
                                    </h5>

                                    <p class="mb-0">
                                        No reports have been
                                        submitted yet.

                                        Reports will appear here
                                        when SafeSpace users
                                        submit reports through
                                        the Mobile App.
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
    @if ($reports->hasPages())

        <div class="mt-4">

            {{ $reports->links('pagination::bootstrap-5') }}

        </div>

    @endif

</div>


<!-- Information Note -->
<div class="report-note mt-4">

    <strong>
        Report Management Information
    </strong>

    <p class="mb-0 mt-2">

        Use the filters to locate reports
        based on their status or content type.

        Open View Details to review the report,
        inspect reported content, update its
        status and record admin notes.

    </p>

</div>

@endsection
