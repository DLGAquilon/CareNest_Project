<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\HealthLog;
use Illuminate\Http\Request;

class HealthLogController extends Controller
{
    public function index()
    {
        return HealthLog::with(['resident', 'caregiver', 'medicationStatus', 'residentStatus'])
            ->orderByDesc('LogTimestamp')->paginate(20);
    }
    public function byResident($id)
    {
        return HealthLog::with(['caregiver', 'medicationStatus', 'residentStatus'])
            ->where('ResidentID', $id)->orderByDesc('LogTimestamp')->get();
    }
    public function store(Request $request)
    {
        $data = $request->validate([
            'ResidentID'         => 'required|exists:Resident,ResidentID',
            'StaffID'            => 'required|exists:Caregiver,StaffID',
            'LogTimestamp'       => 'required|date',
            'SystolicBP'         => 'nullable|integer',
            'DiastolicBP'        => 'nullable|integer',
            'HeartRate'          => 'nullable|integer',
            'Temperature'        => 'nullable|numeric',
            'OxygenSaturation'   => 'nullable|integer',
            'MedicationStatusID' => 'required|exists:StatusLookup,StatusID',
            'ResidentStatusID'   => 'required|exists:StatusLookup,StatusID',
            'CaregiverNotes'     => 'nullable|string',
        ]);
        return response()->json(HealthLog::create($data), 201);
    }
    public function show($id)
    {
        return HealthLog::with(['resident', 'caregiver', 'medicationStatus', 'residentStatus'])->findOrFail($id);
    }
    public function update(Request $request, $id)
    {
        $log = HealthLog::findOrFail($id);
        $log->update($request->only([
            'SystolicBP',
            'DiastolicBP',
            'HeartRate',
            'Temperature',
            'OxygenSaturation',
            'MedicationStatusID',
            'ResidentStatusID',
            'CaregiverNotes',
        ]));
        return response()->json($log);
    }
    public function destroy($id)
    {
        HealthLog::findOrFail($id)->delete();
        return response()->json(['message' => 'Health log deleted.']);
    }
}
