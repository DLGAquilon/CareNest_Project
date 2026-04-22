<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class ShiftSchedule extends Model {
    protected $table      = 'ShiftSchedule';
    protected $primaryKey = 'ShiftID';
    public $timestamps    = false;
    protected $fillable   = ['StaffID','ShiftDay','StartTime','EndTime'];

    public function caregiver() { return $this->belongsTo(Caregiver::class, 'StaffID', 'StaffID'); }
}