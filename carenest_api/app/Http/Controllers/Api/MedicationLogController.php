<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MedicationLog;
use Illuminate\Http\Request;

class MedicationLogController extends Controller
{
    public function index()
    {
        return MedicationLog::with(['resident', 'caregiver', 'status'])
            ->orderByDesc('ScheduledAt')->paginate(20);
    }
    public function byResident($id)
    {
        return MedicationLog::with(['caregiver', 'status'])
            ->where('ResidentID', $id)->orderByDesc('ScheduledAt')->get();
    }
    public function store(Request $request)
    {
        $data = $request->validate([
            'ResidentID'  => 'required|exists:Resident,ResidentID',
            'StaffID'     => 'required|exists:Caregiver,StaffID',
            'MedName'     => 'required|string|max:100',
            'Dosage'      => 'required|string|max:50',
            'ScheduledAt' => 'required|date',
            'StatusID'    => 'required|exists:StatusLookup,StatusID',
            'Notes'       => 'nullable|string',
        ]);
        return response()->json(MedicationLog::create($data), 201);
    }
    public function show($id)
    {
        return MedicationLog::with(['resident', 'caregiver', 'status'])->findOrFail($id);
    }
    public function update(Request $request, $id)
    {
        $m = MedicationLog::findOrFail($id);
        $m->update($request->only(['StatusID', 'Notes', 'MedName', 'Dosage', 'ScheduledAt']));
        return response()->json($m);
    }
    public function destroy($id)
    {
        MedicationLog::findOrFail($id)->delete();
        return response()->json(['message' => 'Medication log deleted.']);
    }
}
