<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class HealthLog extends Model {
    protected $table      = 'HealthLog';
    protected $primaryKey = 'LogID';
    public $timestamps    = false;
    protected $fillable   = [
        'ResidentID','StaffID','LogTimestamp',
        'SystolicBP','DiastolicBP','HeartRate','Temperature','OxygenSaturation',
        'MedicationStatusID','ResidentStatusID','CaregiverNotes',
    ];

    public function resident()          { return $this->belongsTo(Resident::class,   'ResidentID',         'ResidentID'); }
    public function caregiver()         { return $this->belongsTo(Caregiver::class,  'StaffID',            'StaffID'); }
    public function medicationStatus()  { return $this->belongsTo(StatusLookup::class,'MedicationStatusID','StatusID'); }
    public function residentStatus()    { return $this->belongsTo(StatusLookup::class,'ResidentStatusID',  'StatusID'); }
}