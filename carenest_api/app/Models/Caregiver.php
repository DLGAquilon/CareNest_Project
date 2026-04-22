<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class Caregiver extends Authenticatable
{
    use HasApiTokens;

    protected $table      = 'Caregiver';
    protected $primaryKey = 'StaffID';
    public    $timestamps = false;

    protected $fillable = [
        'FirstName',
        'LastName',
        'ContactNumber',
        'AdminID',
        'Username',
        'EmailAddress',
        'Password',
        'IsArchived',
    ];

    protected $hidden = ['Password'];

    protected $casts = [
        'IsArchived' => 'boolean',
    ];

    // Scope: active caregivers only
    public function scopeActive($query)
    {
        return $query->where('IsArchived', 0);
    }

    public function admin()
    {
        return $this->belongsTo(Administrator::class, 'AdminID', 'AdminID');
    }

    public function shifts()
    {
        return $this->hasMany(ShiftSchedule::class, 'StaffID', 'StaffID');
    }

    public function healthLogs()
    {
        return $this->hasMany(HealthLog::class, 'StaffID', 'StaffID');
    }

    public function medicationLogs()
    {
        return $this->hasMany(MedicationLog::class, 'StaffID', 'StaffID');
    }

    public function monitoredItems()
    {
        return $this->hasMany(InventoryMonitoring::class, 'StaffID', 'StaffID');
    }
}