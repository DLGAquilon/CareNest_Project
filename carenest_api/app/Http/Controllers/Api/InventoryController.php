<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Inventory;
use Illuminate\Http\Request;

class InventoryController extends Controller
{
    public function index()
    {
        return Inventory::with(['category', 'admin'])->get();
    }
    public function lowStock()
    {
        return Inventory::with('category')->where('QuantityOnHand', '<', 10)->get();
    }
    public function store(Request $request)
    {
        $data = $request->validate([
            'ItemName'       => 'required|string|max:100',
            'QuantityOnHand' => 'required|integer|min:0',
            'CategoryID'     => 'required|exists:InventoryCategory,CategoryID',
            'AdminID'        => 'required|exists:Administrator,AdminID',
        ]);
        return response()->json(Inventory::create($data), 201);
    }
    public function show($id)
    {
        return Inventory::with(['category', 'admin'])->findOrFail($id);
    }
    public function update(Request $request, $id)
    {
        $item = Inventory::findOrFail($id);
        $item->update($request->only(['ItemName', 'QuantityOnHand', 'CategoryID']));
        return response()->json($item);
    }
    public function destroy($id)
    {
        Inventory::findOrFail($id)->delete();
        return response()->json(['message' => 'Item deleted.']);
    }
}
