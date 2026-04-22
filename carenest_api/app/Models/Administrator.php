<?php

namespace App\Models;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class Administrator extends Authenticatable {
    use HasApiTokens;
    protected $table      = 'Administrator';
    protected $primaryKey = 'AdminID';
    public $timestamps    = false;
    protected $fillable   = ['Username', 'Password', 'EmailAddress'];
    protected $hidden     = ['Password'];
}