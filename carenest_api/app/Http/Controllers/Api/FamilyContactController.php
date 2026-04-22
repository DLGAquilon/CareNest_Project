<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FamilyContact;
use Illuminate\Http\Request;

class FamilyContactController extends Controller
{
    public function index()
    {
        return FamilyContact::with('resident')->get();
    }
    public function byResident($id)
    {
        return FamilyContact::where('ResidentID', $id)->get();
    }
    public function store(Request $request)
    {
        $data = $request->validate([
            'ResidentID'   => 'required|exists:Resident,ResidentID',
            'FirstName'    => 'required|string|max:50',
            'LastName'     => 'required|string|max:50',
            'Relationship' => 'required|string|max:50',
            'PhoneNumber'  => 'required|string|max:20',
            'Address'      => 'required|string|max:255',
            'MOASignedDate' => 'nullable|date',
        ]);
        return response()->json(FamilyContact::create($data), 201);
    }
    public function show($id)
    {
        return FamilyContact::with('resident')->findOrFail($id);
    }
    public function update(Request $request, $id)
    {
        $c = FamilyContact::findOrFail($id);
        $c->update($request->only(['FirstName', 'LastName', 'Relationship', 'PhoneNumber', 'Address', 'MOASignedDate']));
        return response()->json($c);
    }
    public function destroy($id)
    {
        FamilyContact::findOrFail($id)->delete();
        return response()->json(['message' => 'Contact deleted.']);
    }
}
