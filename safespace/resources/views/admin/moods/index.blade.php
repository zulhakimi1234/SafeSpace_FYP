
@extends('admin.layouts.app')

@section('title', 'Manage Mood Records')

@section('page-title', 'Manage Mood Records')

@push('styles')
<style>
    .mood-stat-card {
        background: white;
        padding: 25px;
        border-radius: 12px;
        border-left: 4px solid #5271a5;
        box-shadow: 0 3px 12px rgba(0,0,0,0.05);
        height: 100%;
    }

    .mood-stat-card h6 {
        color: #777;
        margin-bottom: 15px;
    }

    .mood-stat-card h2 {
        color: #344e7a;
        font-size: 36px;
        font-weight: bold;
    }

    .mood-progress {
        height: 18px;
        background: #e9eef5;
        border-radius: 20px;
        overflow: hidden;
    }

    .mood-progress-bar {
        background: #5271a5;
        height: 100%;
        border-radius: 20px;
    }

    .mood-row {
        margin-bottom: 22px;
    }

    .privacy-note {
        background: #eef4fb;
        border-radius: 10px;
        padding: 18px;
        color: #344e7a;
    }
</style>
@endpush

@section('content')

    <!-- Page Description -->
    <div class="content-card mb-4">

        <h5 class="mb-2">
            Mood Check-in Overview
        </h5>

        <p class="text-muted mb-0">
            View overall mood statistics recorded
            by SafeSpace users.
        </p>

    </div>

    <!-- Statistics Cards -->
    <div class="row g-4 mb-4">

        <!-- Total Records -->
        <div class="col-md-6">

            <div class="mood-stat-card">

                <h6>Total Mood Records</h6>

                <h2>
                    {{ number_format($totalMoodRecords) }}
                </h2>

                <small class="text-muted">
                    Valid mood check-ins recorded
                </small>

            </div>

        </div>

        <!-- Average Score -->
        <div class="col-md-6">

            <div class="mood-stat-card">

                <h6>Average Mood Score</h6>

                <h2>
                    @if ($averageMoodScore !== null)

                        {{ number_format($averageMoodScore, 2) }}
                        <small class="fs-6">/ 5</small>

                    @else

                        N/A

                    @endif
                </h2>

                <small class="text-muted">
                    Average across recorded mood scores
                </small>

            </div>

        </div>

    </div>

    <!-- Mood Distribution -->
    <div class="content-card">

        <h5 class="mb-2">
            Mood Score Distribution
        </h5>

        <p class="text-muted mb-4">
            Number of mood check-ins for each
            score from 1 to 5.
        </p>

        @if ($totalMoodRecords > 0)

            @foreach ($distribution as $item)

                @php
                    $percentage = (
                        $item['count'] / $totalMoodRecords
                    ) * 100;
                @endphp

                <div class="mood-row">

                    <div class="d-flex justify-content-between
                                align-items-center mb-2">

                        <strong>
                            Score {{ $item['score'] }}
                        </strong>

                        <span class="text-muted">
                            {{ $item['count'] }} records
                            ({{ number_format($percentage, 1) }}%)
                        </span>

                    </div>

                    <!-- Progress Bar -->
                    <div class="mood-progress">

                        <div
                            class="mood-progress-bar"
                            role="progressbar"
                            style="width: {{ $percentage }}%;"
                            aria-valuenow="{{ $percentage }}"
                            aria-valuemin="0"
                            aria-valuemax="100">
                        </div>

                    </div>

                </div>

            @endforeach

        @else

            <div class="text-center text-muted py-4">
                No mood records found.
            </div>

        @endif

    </div>

    <!-- Privacy Information -->
    <div class="privacy-note mt-4">

        <h6 class="fw-bold mb-2">
            User Privacy
        </h6>

        <p class="mb-0">
            This page displays aggregated mood
            statistics only. Individual user
            identities, personal mood notes,
            and private emotional records
            are not displayed.
        </p>

    </div>

@endsection
