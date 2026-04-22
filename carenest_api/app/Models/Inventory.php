<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Inventory extends Model {
    protected $table      = 'Inventory';
    protected $primaryKey = 'ItemID';
    public $timestamps    = false;
    protected $fillable   = ['ItemName','QuantityOnHand','CategoryID','AdminID'];

    public function category() { return $this->belongsTo(InventoryCategory::class, 'CategoryID', 'CategoryID'); }
    public function admin()    { return $this->belongsTo(Administrator::class,     'AdminID',    'AdminID'); }
}