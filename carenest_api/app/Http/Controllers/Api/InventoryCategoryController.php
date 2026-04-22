<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\InventoryCategory;
use Illuminate\Http\Request;

class InventoryCategoryController extends Controller
{
    public function index()
    {
        return InventoryCategory::all();
    }
    public function store(Request $request)
    {
        $data = $request->validate(['CategoryName' => 'required|string|unique:InventoryCategory,CategoryName']);
        return response()->json(InventoryCategory::create($data), 201);
    }
    public function show($id)
    {
        return InventoryCategory::findOrFail($id);
    }
    public function update(Request $request, $id)
    {
        $c = InventoryCategory::findOrFail($id);
        $c->update($request->validate(['CategoryName' => 'required|string']));
        return response()->json($c);
    }
    public function destroy($id)
    {
        InventoryCategory::findOrFail($id)->delete();
        return response()->json(['message' => 'Category deleted.']);
    }
}
