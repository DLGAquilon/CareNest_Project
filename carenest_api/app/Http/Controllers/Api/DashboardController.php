<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Caregiver;
use App\Models\HealthLog;
use App\Models\Inventory;
use App\Models\Resident;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index()
    {
        /*
         * Critical residents logic:
         * A resident should only appear as critical if their LATEST health log
         * still has a critical/under-observation status.
         * If they were logged as Stable (or any non-critical status) after a
         * critical entry, they should NOT appear in the dashboard alert list.
         */
        $criticalResidents = $this->getActuallyCriticalResidents();

        return response()->json([
            'total_residents'    => Resident::active()->count(),
            'total_caregivers'   => Caregiver::active()->count(),
            'low_stock_count'    => Inventory::where('QuantityOnHand', '<', 10)->count(),
            'logs_today'         => HealthLog::whereDate('LogTimestamp', today())->count(),
            'critical_residents' => $criticalResidents,
        ]);
    }

    /**
     * Returns only residents whose MOST RECENT health log
     * is Critical or Under Observation.
     * Residents logged as Stable (or any other status) after
     * a critical entry are excluded.
     */
    private function getActuallyCriticalResidents(): array
    {
        // Step 1: Get the latest LogID per resident
        $latestLogIds = HealthLog::select(DB::raw('MAX(LogID) as LogID'))
            ->groupBy('ResidentID')
            ->pluck('LogID');

        // Step 2: From those latest logs, keep only critical ones
        $logs = HealthLog::with(['resident', 'residentStatus'])
            ->whereIn('LogID', $latestLogIds)
            ->whereHas('residentStatus', function ($q) {
                $q->whereIn('StatusValue', ['Critical', 'Under Observation']);
            })
            ->orderByDesc('LogTimestamp')
            ->get();

        return $logs->map(function ($log) {
            return [
                'resident_id'     => $log->ResidentID,
                'resident'        => $log->resident->FirstName . ' ' . $log->resident->LastName,
                'status'          => $log->residentStatus->StatusValue ?? '-',
                'log_time'        => $log->LogTimestamp,
                'caregiver_notes' => $log->CaregiverNotes,
            ];
        })->values()->all();
    }
}
