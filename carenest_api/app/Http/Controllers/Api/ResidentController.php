<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FamilyContact;
use App\Models\Resident;
use Illuminate\Http\Request;

class ResidentController extends Controller
{
    /**
     * GET /api/residents
     * Returns only active (non-archived) residents.
     */
    public function index()
    {
        return response()->json(
            Resident::active()->with(['admin', 'familyContacts'])->get()
        );
    }

    /**
     * POST /api/residents
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'FirstName'     => 'required|string|max:50',
            'LastName'      => 'required|string|max:50',
            'BirthDate'     => 'required|date',
            'AdmissionDate' => 'required|date',
            'AdminID'       => 'required|exists:Administrator,AdminID',
        ]);

        return response()->json(Resident::create($data), 201);
    }

    /**
     * GET /api/residents/{id}
     * Returns resident regardless of archive status (detail view shows all).
     */
    public function show($id)
    {
        return response()->json(
            Resident::with([
                'admin',
                'familyContacts',
                'healthLogs.caregiver',
                'healthLogs.medicationStatus',
                'healthLogs.residentStatus',
                'medicationLogs.caregiver',
                'medicationLogs.status',
            ])->findOrFail($id)
        );
    }

    /**
     * PUT /api/residents/{id}
     */
    public function update(Request $request, $id)
    {
        $resident = Resident::findOrFail($id);

        $resident->update($request->validate([
            'FirstName'     => 'sometimes|string|max:50',
            'LastName'      => 'sometimes|string|max:50',
            'BirthDate'     => 'sometimes|date',
            'AdmissionDate' => 'sometimes|date',
        ]));

        return response()->json($resident);
    }

    /**
     * DELETE /api/residents/{id}
     */
    public function destroy($id)
    {
        Resident::findOrFail($id)->delete();
        return response()->json(['message' => 'Resident deleted successfully.']);
    }

    /**
     * PATCH /api/residents/{id}/archive
     * Soft-archives a resident — stays in DB, hidden from list.
     */
    public function archive($id)
    {
        $resident = Resident::findOrFail($id);
        $resident->update(['IsArchived' => 1]);

        return response()->json([
            'message'  => 'Resident archived successfully.',
            'resident' => $resident->only(['ResidentID', 'FirstName', 'LastName', 'IsArchived']),
        ]);
    }

    /**
     * PATCH /api/residents/{id}/restore
     * Restores an archived resident back to active.
     */
    public function restore($id)
    {
        $resident = Resident::findOrFail($id);
        $resident->update(['IsArchived' => 0]);

        return response()->json(['message' => 'Resident restored successfully.']);
    }

    /**
     * POST /api/residents/{id}/contacts
     * Adds a family contact directly from the resident detail screen.
     */
    public function addContact(Request $request, $id)
    {
        // Ensure the resident exists
        Resident::findOrFail($id);

        $data = $request->validate([
            'FirstName'    => 'required|string|max:50',
            'LastName'     => 'required|string|max:50',
            'Relationship' => 'required|string|max:50',
            'PhoneNumber'  => 'required|string|max:20',
            'Address'      => 'required|string|max:255',
            'MOASignedDate'=> 'nullable|date',
        ]);

        $contact = FamilyContact::create([
            'ResidentID'   => $id,
            'FirstName'    => $data['FirstName'],
            'LastName'     => $data['LastName'],
            'Relationship' => $data['Relationship'],
            'PhoneNumber'  => $data['PhoneNumber'],
            'Address'      => $data['Address'],
            'MOASignedDate'=> $data['MOASignedDate'] ?? null,
        ]);

        return response()->json($contact, 201);
    }
}