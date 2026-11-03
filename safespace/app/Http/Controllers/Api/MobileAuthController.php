<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class MobileAuthController extends Controller
{
    // REGISTER MOBILE USER
    public function register(Request $request)
    {
        $validated = $request->validate([
            'username' => [
                'required',
                'string',
                'min:3',
                'max:50',
                Rule::unique('users', 'username'),
            ],
            'email' => [
                'required',
                'email',
                'max:255',
                Rule::unique('users', 'email'),
            ],
            'password' => [
                'required',
                'string',
                'min:8',
                'confirmed',
            ],
        ]);

        $user = new User();

        $user->username = trim($validated['username']);
        $user->email = strtolower(
            trim($validated['email'])
        );
        $user->password = Hash::make(
            $validated['password']
        );

        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Account registered successfully.',
            'user' => [
                'id' => $user->id,
                'username' => $user->username,
                'email' => $user->email,
            ],
        ], 201);
    }

    // LOGIN MOBILE USER
    public function login(Request $request)
    {
        $validated = $request->validate([
            'email' => [
                'required',
                'email',
            ],
            'password' => [
                'required',
                'string',
            ],
        ]);

        $email = strtolower(
            trim($validated['email'])
        );

        $user = User::where('email', $email)->first();

        // Verify login credentials
        if (
            !$user ||
            !Hash::check(
                $validated['password'],
                $user->password
            )
        ) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid email or password.',
            ], 401);
        }

        // Create Sanctum token, valid for 30 days
        $token = $user->createToken(
            'safespace-mobile',
            ['*'],
            now()->addDays(30)
        )->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful.',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'username' => $user->username,
                'email' => $user->email,
            ],
        ], 200);
    }

    // GET LOGGED-IN USER
    public function me(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'user' => [
                'id' => $user->id,
                'username' => $user->username,
                'email' => $user->email,
            ],
        ]);
    }

    // LOGOUT MOBILE USER
    public function logout(Request $request)
    {
        // Revoke the token used for this request
        $request->user()
            ->currentAccessToken()
            ?->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully.',
        ]);
    }
}
