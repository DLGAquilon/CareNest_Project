<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Resident extends Model
{
    protected $table      = 'Resident';
    protected $primaryKey = 'ResidentID';
    public    $timestamps = false;

    protected $fillable = [
        'FirstName',
        'LastName',
        'BirthDate',
        'AdmissionDate',
        'AdminID',
        'IsArchived',
    ];

    protected $casts = [
        'IsArchived' => 'boolean',
    ];

    // Scope: active residents only (default list view)
    public function scopeActive($query)
    {
        return $query->where('IsArchived', 0);
    }

    public function admin()
    {
        return $this->belongsTo(Administrator::class, 'AdminID', 'AdminID');
    }

    public function familyContacts()
    {
        return $this->hasMany(FamilyContact::class, 'ResidentID', 'ResidentID');
    }

    public function healthLogs()
    {
        return $this->hasMany(HealthLog::class, 'ResidentID', 'ResidentID');
    }

    public function medicationLogs()
    {
        return $this->hasMany(MedicationLog::class, 'ResidentID', 'ResidentID');
    }
}
