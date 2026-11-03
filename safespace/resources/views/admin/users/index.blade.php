
@extends('admin.layouts.app')

@section('title', 'Manage Users')

@section('page-title', 'Manage Users')

@section('content')

<div class="content-card">

    <!-- Section Header -->
    <div class="d-flex justify-content-between
                align-items-center mb-4">

        <div>
            <h5 class="mb-1">
                Registered Users
            </h5>

            <p class="text-muted mb-0">
                Search and filter registered SafeSpace users.
            </p>
        </div>

        <span class="badge bg-primary">
            Total: {{ $users->total() }}
        </span>

    </div>

    <!-- Search and Filter Form -->
    <form method="GET"
          action="{{ route('admin.users.index') }}"
          class="mb-4">

        <div class="row g-3">

            <!-- Search Input -->
            <div class="col-md-5">

                <label class="form-label">
                    Search User
                </label>

                <input
                    type="text"
                    name="search"
                    class="form-control"
                    placeholder="Search username or email..."
                    value="{{ $search }}"
                    maxlength="100"
                >

            </div>

            <!-- Account Status Filter -->
            <div class="col-md-4">

                <label class="form-label">
                    Account Status
                </label>

                <select
                    name="status"
                    class="form-select">

                    <option value="all"
                        {{ $status === 'all' ? 'selected' : '' }}>
                        All Users
                    </option>

                    <option value="active"
                        {{ $status === 'active' ? 'selected' : '' }}>
                        Active Users
                    </option>

                    <option value="inactive"
                        {{ $status === 'inactive' ? 'selected' : '' }}>
                        Inactive Users
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
                    href="{{ route('admin.users.index') }}"
                    class="btn btn-outline-secondary w-100">

                    Clear

                </a>

            </div>

        </div>

    </form>

    <!-- Validation Errors -->
    @if ($errors->any())

        <div class="alert alert-danger">
            {{ $errors->first() }}
        </div>

    @endif

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

                Account Status:
                <strong>{{ ucfirst($status) }}</strong>

                <br>

            @endif

            Found {{ $users->total() }} user(s).

        </div>

    @endif

    <!-- Users Table -->
    <div class="table-responsive">

        <table class="table table-hover">

            <thead>

                <tr>
                    <th>ID</th>
                    <th>Username</th>
                    <th>Email</th>
                    <th>Account Status</th>
                    <th>Last Login</th>
                    <th>Registered Date</th>
                    <th>Action</th>
                </tr>

            </thead>

            <tbody>

                @forelse ($users as $user)

                    <tr>

                        <!-- User ID -->
                        <td>
                            {{ $user->id }}
                        </td>

                        <!-- Username -->
                        <td>
                            <strong>
                                {{ $user->username }}
                            </strong>
                        </td>

                        <!-- Email -->
                        <td>
                            {{ $user->email }}
                        </td>

                        <!-- Account Status -->
                        <td>

                            @if ($user->account_status === 'active')

                                <span class="badge bg-success">
                                    Active
                                </span>

                            @elseif ($user->account_status === 'inactive')

                                <span class="badge bg-danger">
                                    Inactive
                                </span>

                            @else

                                <span class="badge bg-secondary">
                                    Unknown
                                </span>

                            @endif

                        </td>

                        <!-- Last Login -->
                        <td>

                            @if ($user->last_login_at)

                                {{ \Carbon\Carbon::parse($user->last_login_at)->format('d M Y, h:i A') }}

                            @else

                                <span class="text-muted">
                                    Never
                                </span>

                            @endif

                        </td>

                        <!-- Registered Date -->
                        <td>

                            @if ($user->created_at)

                                {{ \Carbon\Carbon::parse($user->created_at)->format('d M Y') }}

                            @else

                                -

                            @endif

                        </td>

                        <!-- Action -->
                        <td>

                            <a
                                href="{{ route('admin.users.show', ['id' => $user->id]) }}"
                                class="btn btn-sm btn-primary text-nowrap">

                                View Details

                            </a>

                        </td>

                    </tr>

                @empty

                    <tr>

                        <td colspan="7"
                            class="text-center text-muted py-4">

                            @if ($search !== '' || $status !== 'all')

                                No users found matching your filters.

                            @else

                                No registered users found.

                            @endif

                        </td>

                    </tr>

                @endforelse

            </tbody>

        </table>

    </div>

    <!-- Pagination -->
    @if ($users->hasPages())

        <div class="mt-4">

            {{ $users->links('pagination::bootstrap-5') }}

        </div>

    @endif

</div>

@endsection
