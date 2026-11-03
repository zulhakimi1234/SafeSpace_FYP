
<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>
        @yield('title', 'SafeSpace Admin')
    </title>

    <!-- Bootstrap CSS -->
    <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
        rel="stylesheet"
    >

    <style>

        /* Body */
        body {
            margin: 0;
            background: #f4f7fb;
            font-family: Arial, sans-serif;
        }

        /* Sidebar */
        .sidebar {
            width: 250px;
            min-height: 100vh;
            background: #344e7a;
            padding: 25px 15px;
            position: fixed;
            top: 0;
            left: 0;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
            max-height: 100vh;
        }

        /* Sidebar Title */
        .sidebar h3 {
            color: white;
            text-align: center;
            margin-bottom: 35px;
            font-weight: bold;
        }

        /* Sidebar Links */
        .sidebar a {
            display: block;
            padding: 12px 15px;
            margin-bottom: 8px;
            color: white;
            text-decoration: none;
            border-radius: 8px;
            transition: background 0.2s ease;
        }

        /* Active and Hover Links */
        .sidebar a:hover,
        .sidebar a.active {
            background: #5271a5;
            color: white;
        }

        /* Logout Section */
        .logout-section {
            margin-top: auto;
            padding-top: 20px;
        }

        .btn-logout {
            background: #dc3545;
            border: none;
            color: white;
            width: 100%;
            padding: 12px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
        }

        .btn-logout:hover {
            background: #bb2d3b;
        }

        /* Main Content */
        .main-content {
            margin-left: 250px;
            padding: 30px;
            min-height: 100vh;
        }

        /* Top Bar */
        .topbar {
            background: white;
            border-radius: 12px;
            padding: 22px 25px;
            margin-bottom: 30px;
            box-shadow: 0 3px 12px rgba(0,0,0,0.05);
        }

        .topbar h4 {
            color: #344e7a;
            font-weight: bold;
        }

        /* Default Statistics Card */
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 12px;
            border-left: 4px solid #5271a5;
            box-shadow: 0 3px 12px rgba(0,0,0,0.05);
        }

        .stat-card h6 {
            color: #777;
        }

        .stat-card h2 {
            color: #344e7a;
            font-size: 36px;
        }

        /* Content Card */
        .content-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 3px 12px rgba(0,0,0,0.05);
        }

        /* Table Header */
        .table thead th {
            background: #eef4fb;
            color: #344e7a;
            font-weight: 600;
            white-space: nowrap;
        }

        /* Responsive Layout */
        @media (max-width: 768px) {

            .sidebar {
                position: static;
                width: 100%;
                min-height: auto;
                max-height: none;
                overflow-y: visible;
            }

            .sidebar h3 {
                margin-bottom: 20px;
            }

            .main-content {
                margin-left: 0;
                padding: 15px;
            }

            .topbar {
                padding: 20px;
            }

            .content-card {
                padding: 18px;
            }

        }

    </style>

    <!-- Additional Page Styles -->
    @stack('styles')

</head>

<body>

    <!-- Sidebar -->
    <div class="sidebar">

        <!-- System Title -->
        <h3>
            SafeSpace
        </h3>

        <!-- Dashboard -->
        <a
            href="{{ route('admin.dashboard') }}"
            class="{{ request()->routeIs('admin.dashboard') ? 'active' : '' }}"
        >
            Dashboard
        </a>

        <!-- Manage Users -->
        <a
            href="{{ route('admin.users.index') }}"
            class="{{ request()->routeIs('admin.users.*') ? 'active' : '' }}"
        >
            Manage Users
        </a>

        <!-- Manage Journals -->
        <a
            href="{{ route('admin.journals.index') }}"
            class="{{ request()->routeIs('admin.journals.*') ? 'active' : '' }}"
        >
            Manage Journals
        </a>

        <!-- Manage Replies -->
        <a
            href="{{ route('admin.replies.index') }}"
            class="{{ request()->routeIs('admin.replies.*') ? 'active' : '' }}"
        >
            Manage Replies
        </a>

        <!-- Manage Mood Records -->
        <a
            href="{{ route('admin.moods.index') }}"
            class="{{ request()->routeIs('admin.moods.*') ? 'active' : '' }}"
        >
            Manage Mood Records
        </a>

        <!-- Manage Reports -->
        <a
            href="{{ route('admin.reports.index') }}"
            class="{{ request()->routeIs('admin.reports.*') ? 'active' : '' }}"
        >
            Manage Reports
        </a>

        <!-- Manage Tips and Articles -->
        <a
            href="{{ route('admin.tips.index') }}"
            class="{{ request()->routeIs('admin.tips.*') ? 'active' : '' }}"
        >
            Manage Tips &amp; Articles
        </a>

        <!-- Logout -->
        <div class="logout-section">

            <form
                method="POST"
                action="{{ route('admin.logout') }}"
            >

                @csrf

                <button
                    type="submit"
                    class="btn-logout"
                >
                    Logout
                </button>

            </form>

        </div>

    </div>


    <!-- Main Content -->
    <div class="main-content">

        <!-- Top Bar -->
        <div class="topbar">

            <h4 class="mb-2">
                @yield('page-title', 'Admin Panel')
            </h4>

            <p class="text-muted mb-0">
                Welcome back,
                {{ Auth::guard('admin')->user()->name }}!
            </p>

        </div>

        <!-- Page Content -->
        @yield('content')

    </div>


    <!-- Bootstrap JavaScript -->
    <script
        src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
    ></script>

    <!-- Additional Page Scripts -->
    @stack('scripts')

</body>

</html>
