
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Admin Login | SafeSpace</title>

    <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
        rel="stylesheet"
    >

    <style>
        body {
            background: #f0f4f8;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: Arial, sans-serif;
        }

        .login-card {
            width: 100%;
            max-width: 420px;
            padding: 35px;
            border-radius: 15px;
            background: white;
            box-shadow: 0 5px 25px rgba(0, 0, 0, 0.08);
        }

        .brand-title {
            color: #5271a5;
            font-weight: bold;
        }

        .btn-login {
            background: #5271a5;
            color: white;
            padding: 12px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
        }

        .btn-login:hover {
            background: #3d5b89;
            color: white;
        }

        .form-control {
            padding: 12px;
            border-radius: 8px;
        }
    </style>
</head>

<body>

    <div class="login-card">

        <!-- SafeSpace Logo -->
        <div class="text-center mb-4">
            <h2 class="brand-title">SafeSpace</h2>
            <p class="text-muted">
                Admin Management System
            </p>
        </div>

        <h5 class="text-center mb-4">
            Admin Login
        </h5>

        <!-- Display Login Error -->
        @if ($errors->any())
            <div class="alert alert-danger">
                {{ $errors->first() }}
            </div>
        @endif

        <!-- Login Form -->
        <form
            method="POST"
            action="{{ route('admin.login.submit') }}"
        >

            @csrf

            <!-- Email -->
            <div class="mb-3">
                <label for="email" class="form-label">
                    Email Address
                </label>

                <input
                    type="email"
                    id="email"
                    name="email"
                    class="form-control"
                    placeholder="Enter admin email"
                    value="{{ old('email') }}"
                    autocomplete="username"
                    required
                >
            </div>

            <!-- Password -->
            <div class="mb-4">
                <label for="password" class="form-label">
                    Password
                </label>

                <input
                    type="password"
                    id="password"
                    name="password"
                    class="form-control"
                    placeholder="Enter password"
                    autocomplete="current-password"
                    required
                >
            </div>

            <!-- Login Button -->
            <button
                type="submit"
                class="btn btn-login w-100"
            >
                Login
            </button>

        </form>

        <p class="text-center text-muted mt-4 mb-0">
            SafeSpace Administration
        </p>

    </div>

</body>
</html>
