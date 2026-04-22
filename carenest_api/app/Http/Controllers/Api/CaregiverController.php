<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Caregiver;
use Illuminate\Http\Request;

class CaregiverController extends Controller
{
    /**
     * GET /api/caregivers
     * Returns only active (non-archived) caregivers.
     */
    public function index()
    {
        return response()->json(
            Caregiver::active()->with(['admin', 'shifts'])->get()
        );
    }

    /**
     * POST /api/caregivers
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'FirstName'     => 'required|string|max:50',
            'LastName'      => 'required|string|max:50',
            'ContactNumber' => 'required|string|max:20',
            'AdminID'       => 'required|exists:Administrator,AdminID',
        ]);

        return response()->json(Caregiver::create($data), 201);
    }

    /**
     * GET /api/caregivers/{id}
     */
    public function show($id)
    {
        return response()->json(
            Caregiver::with(['admin', 'shifts', 'healthLogs', 'monitoredItems.item'])
                ->findOrFail($id)
        );
    }

    /**
     * PUT /api/caregivers/{id}
     */
    public function update(Request $request, $id)
    {
        $caregiver = Caregiver::findOrFail($id);
        $caregiver->update($request->validate([
            'FirstName'     => 'sometimes|string|max:50',
            'LastName'      => 'sometimes|string|max:50',
            'ContactNumber' => 'sometimes|string|max:20',
        ]));
        return response()->json($caregiver);
    }

    /**
     * DELETE /api/caregivers/{id}
     */
    public function destroy($id)
    {
        Caregiver::findOrFail($id)->delete();
        return response()->json(['message' => 'Caregiver deleted successfully.']);
    }

    /**
     * PATCH /api/caregivers/{id}/archive
     * Soft-archives a caregiver — stays in DB, hidden from list.
     */
    public function archive($id)
    {
        $caregiver = Caregiver::findOrFail($id);
        $caregiver->update(['IsArchived' => 1]);

        return response()->json([
            'message'   => 'Caregiver archived successfully.',
            'caregiver' => $caregiver->only(['StaffID', 'FirstName', 'LastName', 'IsArchived']),
        ]);
    }

    /**
     * PATCH /api/caregivers/{id}/restore
     * Restores an archived caregiver.
     */
    public function restore($id)
    {
        $caregiver = Caregiver::findOrFail($id);
        $caregiver->update(['IsArchived' => 0]);
        return response()->json(['message' => 'Caregiver restored successfully.']);
    }
}