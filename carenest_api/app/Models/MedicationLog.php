<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class MedicationLog extends Model {
    protected $table      = 'MedicationLog';
    protected $primaryKey = 'MedLogID';
    public $timestamps    = false;
    protected $fillable   = ['ResidentID','StaffID','MedName','Dosage','ScheduledAt','StatusID','Notes'];

    public function resident() { return $this->belongsTo(Resident::class,    'ResidentID', 'ResidentID'); }
    public function caregiver(){ return $this->belongsTo(Caregiver::class,   'StaffID',    'StaffID'); }
    public function status()   { return $this->belongsTo(StatusLookup::class,'StatusID',   'StatusID'); }
}