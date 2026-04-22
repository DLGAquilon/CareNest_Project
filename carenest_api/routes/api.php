<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ResidentController;
use App\Http\Controllers\Api\CaregiverController;
use App\Http\Controllers\Api\HealthLogController;
use App\Http\Controllers\Api\MedicationLogController;
use App\Http\Controllers\Api\InventoryController;
use App\Http\Controllers\Api\FamilyContactController;
use App\Http\Controllers\Api\ShiftScheduleController;
use App\Http\Controllers\Api\DashboardController;

// ── Public routes ─────────────────────────────────────────────
Route::post('/login',    [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// Forgot password — 2-step, no auth required
Route::post('/forgot-password/verify', [AuthController::class, 'forgotPasswordVerify']);
Route::post('/forgot-password/reset',  [AuthController::class, 'forgotPasswordReset']);

// ── Protected routes ──────────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {

    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me',      [AuthController::class, 'me']);

    // Dashboard
    Route::get('/dashboard', [DashboardController::class, 'index']);

    // Residents — CRUD + archive/restore + add contact
    Route::apiResource('residents', ResidentController::class);
    Route::patch('residents/{id}/archive', [ResidentController::class, 'archive']);
    Route::patch('residents/{id}/restore', [ResidentController::class, 'restore']);
    Route::post('residents/{id}/contacts', [ResidentController::class, 'addContact']);
    Route::get('residents/{id}/health-logs',    [HealthLogController::class,    'byResident']);
    Route::get('residents/{id}/medication-logs', [MedicationLogController::class, 'byResident']);

    // Caregivers — CRUD + archive/restore
    Route::apiResource('caregivers', CaregiverController::class);
    Route::patch('caregivers/{id}/archive', [CaregiverController::class, 'archive']);
    Route::patch('caregivers/{id}/restore', [CaregiverController::class, 'restore']);
    Route::get('caregivers/{id}/shifts',    [ShiftScheduleController::class, 'byCaregiver']);

    // Shifts
    Route::apiResource('shifts', ShiftScheduleController::class);

    // Health Logs
    Route::apiResource('health-logs', HealthLogController::class);

    // Medication Logs
    Route::apiResource('medication-logs', MedicationLogController::class);

    // Inventory
    Route::get('/inventory/low-stock',           [InventoryController::class, 'lowStock']);
    Route::apiResource('inventory',               InventoryController::class);
    Route::apiResource('inventory-categories',    \App\Http\Controllers\Api\InventoryCategoryController::class);

    // Family Contacts
    Route::get('residents/{id}/contacts', [FamilyContactController::class, 'byResident']);
    Route::apiResource('contacts', FamilyContactController::class);

    // Status Lookup
    Route::get('/statuses',            [\App\Http\Controllers\Api\StatusLookupController::class, 'index']);
    Route::get('/statuses/{category}', [\App\Http\Controllers\Api\StatusLookupController::class, 'byCategory']);
});