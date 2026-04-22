<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\StatusLookup;

class StatusLookupController extends Controller
{
    public function index()
    {
        return StatusLookup::all();
    }
    public function byCategory($cat)
    {
        return StatusLookup::where('Category', $cat)->get();
    }
}
