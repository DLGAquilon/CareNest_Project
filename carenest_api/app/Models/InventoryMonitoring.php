<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class InventoryMonitoring extends Model
{
    protected $table      = 'Inventory_Monitoring';
    protected $primaryKey = 'MonitoringID';
    public    $timestamps = false;

    protected $fillable = [
        'StaffID',
        'ItemID',
        'LastChecked',
        'Remarks',
    ];

    // Monitoring record belongs to one Caregiver
    public function caregiver()
    {
        return $this->belongsTo(Caregiver::class, 'StaffID', 'StaffID');
    }

    // Monitoring record belongs to one Inventory item
    public function item()
    {
        return $this->belongsTo(Inventory::class, 'ItemID', 'ItemID');
    }
}
