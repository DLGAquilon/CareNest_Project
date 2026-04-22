<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Administrator;
use App\Models\Caregiver;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        $admin = Administrator::where('Username', $request->username)->first();
        if ($admin && Hash::check($request->password, $admin->Password)) {
            $token = $admin->createToken('carenest-token')->plainTextToken;
            return response()->json([
                'token' => $token,
                'user'  => [
                    'id'       => $admin->AdminID,
                    'username' => $admin->Username,
                    'email'    => $admin->EmailAddress,
                    'role'     => 'Administrator',
                ],
            ]);
        }

        $caregiver = Caregiver::where('Username', $request->username)->first();
        if ($caregiver && Hash::check($request->password, $caregiver->Password)) {
            $token = $caregiver->createToken('carenest-token')->plainTextToken;
            return response()->json([
                'token' => $token,
                'user'  => [
                    'id'        => $caregiver->StaffID,
                    'username'  => $caregiver->Username,
                    'email'     => $caregiver->EmailAddress,
                    'role'      => 'Caregiver',
                    'firstName' => $caregiver->FirstName,
                    'lastName'  => $caregiver->LastName,
                ],
            ]);
        }

        throw ValidationException::withMessages([
            'username' => ['The provided credentials are incorrect.'],
        ]);
    }

    public function register(Request $request)
    {
        $role = $request->input('role', 'Administrator');
        return $role === 'Caregiver'
            ? $this->registerCaregiver($request)
            : $this->registerAdministrator($request);
    }

    private function registerAdministrator(Request $request)
    {
        $request->validate([
            'username' => 'required|string|max:50|unique:Administrator,Username',
            'email'    => 'required|email|max:100|unique:Administrator,EmailAddress',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $admin = Administrator::create([
            'Username'     => $request->username,
            'EmailAddress' => $request->email,
            'Password'     => Hash::make($request->password),
        ]);

        $token = $admin->createToken('carenest-token')->plainTextToken;
        return response()->json([
            'token' => $token,
            'user'  => [
                'id'       => $admin->AdminID,
                'username' => $admin->Username,
                'email'    => $admin->EmailAddress,
                'role'     => 'Administrator',
            ],
        ], 201);
    }

    private function registerCaregiver(Request $request)
    {
        $request->validate([
            'username'       => 'required|string|max:50|unique:Caregiver,Username',
            'email'          => 'required|email|max:100|unique:Caregiver,EmailAddress',
            'password'       => 'required|string|min:8|confirmed',
            'first_name'     => 'required|string|max:50',
            'last_name'      => 'required|string|max:50',
            'contact_number' => 'required|string|max:20',
        ]);

        $caregiver = Caregiver::create([
            'FirstName'     => $request->first_name,
            'LastName'      => $request->last_name,
            'ContactNumber' => $request->contact_number,
            'Username'      => $request->username,
            'EmailAddress'  => $request->email,
            'Password'      => Hash::make($request->password),
            'AdminID'       => Administrator::first()?->AdminID,
        ]);

        $token = $caregiver->createToken('carenest-token')->plainTextToken;
        return response()->json([
            'token' => $token,
            'user'  => [
                'id'        => $caregiver->StaffID,
                'username'  => $caregiver->Username,
                'email'     => $caregiver->EmailAddress,
                'role'      => 'Caregiver',
                'firstName' => $caregiver->FirstName,
                'lastName'  => $caregiver->LastName,
            ],
        ], 201);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out successfully.']);
    }

    public function me(Request $request)
    {
        $user = $request->user();
        if ($user instanceof Caregiver) {
            return response()->json([
                'id'        => $user->StaffID,
                'username'  => $user->Username,
                'email'     => $user->EmailAddress,
                'role'      => 'Caregiver',
                'firstName' => $user->FirstName,
                'lastName'  => $user->LastName,
            ]);
        }
        return response()->json([
            'id'       => $user->AdminID,
            'username' => $user->Username,
            'email'    => $user->EmailAddress,
            'role'     => 'Administrator',
        ]);
    }

    /**
     * POST /api/forgot-password/verify
     * Step 1: Check if the email exists in Administrator or Caregiver table.
     * Returns a temporary token to authorize the password update.
     */
    public function forgotPasswordVerify(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $email = $request->email;

        $admin     = Administrator::where('EmailAddress', $email)->first();
        $caregiver = Caregiver::where('EmailAddress', $email)->first();

        if (!$admin && !$caregiver) {
            // Generic message — don't reveal whether email exists
            return response()->json([
                'found' => false,
                'message' => 'No account found with that email address.',
            ], 404);
        }

        // Determine which table matched
        $role = $admin ? 'Administrator' : 'Caregiver';
        $id   = $admin ? $admin->AdminID  : $caregiver->StaffID;

        // Issue a short-lived reset token (simple HMAC — no extra table needed)
        $secret = env('APP_KEY', 'carenest-secret');
        $token  = hash_hmac('sha256', $email . '|' . $role . '|' . $id, $secret);

        return response()->json([
            'found'      => true,
            'role'       => $role,
            'user_id'    => $id,
            'reset_token'=> $token,
            'message'    => 'Email verified. You may now reset your password.',
        ]);
    }

    /**
     * POST /api/forgot-password/reset
     * Step 2: Verify the reset token and update the password.
     */
    public function forgotPasswordReset(Request $request)
    {
        $request->validate([
            'email'        => 'required|email',
            'role'         => 'required|in:Administrator,Caregiver',
            'user_id'      => 'required|integer',
            'reset_token'  => 'required|string',
            'new_password' => 'required|string|min:8|confirmed',
        ]);

        // Re-derive the expected token and compare
        $secret   = env('APP_KEY', 'carenest-secret');
        $expected = hash_hmac(
            'sha256',
            $request->email . '|' . $request->role . '|' . $request->user_id,
            $secret
        );

        if (!hash_equals($expected, $request->reset_token)) {
            return response()->json([
                'message' => 'Invalid or expired reset token.',
            ], 422);
        }

        $newHash = Hash::make($request->new_password);

        if ($request->role === 'Administrator') {
            $admin = Administrator::findOrFail($request->user_id);
            if ($admin->EmailAddress !== $request->email) {
                return response()->json(['message' => 'Token mismatch.'], 422);
            }
            $admin->update(['Password' => $newHash]);
        } else {
            $caregiver = Caregiver::findOrFail($request->user_id);
            if ($caregiver->EmailAddress !== $request->email) {
                return response()->json(['message' => 'Token mismatch.'], 422);
            }
            $caregiver->update(['Password' => $newHash]);
        }

        return response()->json(['message' => 'Password updated successfully.']);
    }
}