<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class InventoryCategory extends Model {
    protected $table      = 'InventoryCategory';
    protected $primaryKey = 'CategoryID';
    public $timestamps    = false;
    protected $fillable   = ['CategoryName'];
}