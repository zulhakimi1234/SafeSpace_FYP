
@extends('admin.layouts.app')

@section('title', 'User Details')

@section('page-title', 'User Details')

@push('styles')
<style>
    .user-avatar {
        width: 70px;
        height: 70px;
        border-radius: 50%;
        background: #e7edf7;
        color: #344e7a;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 28px;
        font-weight: bold;
    }

    .user-info-row {
        padding: 18px 0;
        border-bottom: 1px solid #e9ecef;
    }

    .user-info-label {
        color: #777;
        font-weight: 500;
    }

    .user-info-value {
        color: #344e7a;
        font-weight: 600;
        overflow-wrap: anywhere;
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

    .account-management {
        background: #f8fafd;
        border: 1px solid #e3eaf4;
        padding: 25px;
        border-radius: 12px;
        margin-top: 30px;
    }

    .status-button {
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

    <!-- Validation Errors -->
    @if ($errors->any())

        <div class="alert alert-danger">
            {{ $errors->first() }}
        </div>

    @endif

    <!-- User Header -->
    <div class="d-flex align-items-center gap-3 mb-4">

        <div class="user-avatar">
            {{ strtoupper(substr($user->username ?? 'U', 0, 1)) }}
        </div>

        <div>
            <h4 class="mb-1">
                {{ $user->username }}
            </h4>

            <p class="text-muted mb-0">
                Registered SafeSpace User
            </p>
        </div>

    </div>

    <hr>

    <h5 class="mb-4">
        Account Information
    </h5>

    <!-- User ID -->
    <div class="row user-info-row">

        <div class="col-md-4 user-info-label">
            User ID
        </div>

        <div class="col-md-8 user-info-value">
            {{ $user->id }}
        </div>

    </div>

    <!-- Username -->
    <div class="row user-info-row">

        <div class="col-md-4 user-info-label">
            Username
        </div>

        <div class="col-md-8 user-info-value">
            {{ $user->username }}
        </div>

    </div>

    <!-- Email -->
    <div class="row user-info-row">

        <div class="col-md-4 user-info-label">
            Email Address
        </div>

        <div class="col-md-8 user-info-value">
            {{ $user->email }}
        </div>

    </div>

    <!-- Account Status -->
    <div class="row user-info-row">

        <div class="col-md-4 user-info-label">
            Account Status
        </div>

        <div class="col-md-8">

            @if ($user->account_status === 'active')

                <span class="badge bg-success fs-6">
                    Active
                </span>

            @elseif ($user->account_status === 'inactive')

                <span class="badge bg-danger fs-6">
                    Inactive
                </span>

            @else

                <span class="badge bg-secondary fs-6">
                    Unknown
                </span>

            @endif

        </div>

    </div>

    <!-- Last Login -->
    <div class="row user-info-row">

        <div class="col-md-4 user-info-label">
            Last Login
        </div>

        <div class="col-md-8 user-info-value">

            @if ($user->last_login_at)

                {{ \Carbon\Carbon::parse($user->last_login_at)->format('d M Y, h:i A') }}

            @else

                Never

            @endif

        </div>

    </div>

    <!-- Registered Date -->
    <div class="row user-info-row">

        <div class="col-md-4 user-info-label">
            Registered Date
        </div>

        <div class="col-md-8 user-info-value">

            @if ($user->created_at)

                {{ \Carbon\Carbon::parse($user->created_at)->format('d M Y, h:i A') }}

            @else

                -

            @endif

        </div>

    </div>

    <!-- Account Management Section -->
    <div class="account-management">

        <h5 class="mb-3">
            Account Management
        </h5>

        @if ($user->account_status === 'active')

            <p class="text-muted">
                This account is currently active.

                You can deactivate the account
                using the button below.
            </p>

            <!-- Deactivate Form -->
            <form
                method="POST"
                action="{{ route('admin.users.updateStatus', ['id' => $user->id]) }}"
                onsubmit="return confirm('Are you sure you want to deactivate this user account?');"
            >

                @csrf
                @method('PATCH')

                <input
                    type="hidden"
                    name="account_status"
                    value="inactive"
                >

                <button
                    type="submit"
                    class="btn btn-danger status-button">

                    Deactivate Account

                </button>

            </form>

        @elseif ($user->account_status === 'inactive')

            <p class="text-muted">
                This account is currently inactive.

                You can activate the account
                using the button below.
            </p>

            <!-- Activate Form -->
            <form
                method="POST"
                action="{{ route('admin.users.updateStatus', ['id' => $user->id]) }}"
                onsubmit="return confirm('Are you sure you want to activate this user account?');"
            >

                @csrf
                @method('PATCH')

                <input
                    type="hidden"
                    name="account_status"
                    value="active"
                >

                <button
                    type="submit"
                    class="btn btn-success status-button">

                    Activate Account

                </button>

            </form>

        @else

            <div class="alert alert-warning mb-0">
                Unknown account status.
                Account management is unavailable.
            </div>

        @endif

    </div>

    <!-- Back Button -->
    <div class="mt-4">

        <a
            href="{{ route('admin.users.index') }}"
            class="btn-back">

            &larr; Back to Users

        </a>

    </div>

</div>

@endsection
