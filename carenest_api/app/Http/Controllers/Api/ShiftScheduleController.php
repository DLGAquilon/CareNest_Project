<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ShiftSchedule;
use Illuminate\Http\Request;

class ShiftScheduleController extends Controller
{
    public function index()
    {
        return ShiftSchedule::with('caregiver')->get();
    }
    public function byCaregiver($id)
    {
        return ShiftSchedule::where('StaffID', $id)->get();
    }
    public function store(Request $request)
    {
        $data = $request->validate([
            'StaffID'   => 'required|exists:Caregiver,StaffID',
            'ShiftDay'  => 'required|string',
            'StartTime' => 'required',
            'EndTime'   => 'required',
        ]);
        return response()->json(ShiftSchedule::create($data), 201);
    }
    public function show($id)
    {
        return ShiftSchedule::with('caregiver')->findOrFail($id);
    }
    public function update(Request $request, $id)
    {
        $s = ShiftSchedule::findOrFail($id);
        $s->update($request->only(['ShiftDay', 'StartTime', 'EndTime']));
        return response()->json($s);
    }
    public function destroy($id)
    {
        ShiftSchedule::findOrFail($id)->delete();
        return response()->json(['message' => 'Shift deleted.']);
    }
}
