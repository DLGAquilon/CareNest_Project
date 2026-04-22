<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class FamilyContact extends Model {
    protected $table      = 'FamilyContact';
    protected $primaryKey = 'ContactID';
    public $timestamps    = false;
    protected $fillable   = ['ResidentID','FirstName','LastName','Relationship','PhoneNumber','Address','MOASignedDate'];

    public function resident() { return $this->belongsTo(Resident::class, 'ResidentID', 'ResidentID'); }
}