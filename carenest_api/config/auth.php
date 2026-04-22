<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Authentication Defaults
    |--------------------------------------------------------------------------
    */

    'defaults' => [
        'guard'     => 'web',
        'passwords' => 'administrators',
    ],

    /*
    |--------------------------------------------------------------------------
    | Authentication Guards
    |--------------------------------------------------------------------------
    | We define two API guards — one for Administrator tokens,
    | one for Caregiver tokens. Sanctum checks both when resolving
    | the authenticated user from a Bearer token.
    |--------------------------------------------------------------------------
    */

    'guards' => [
        'web' => [
            'driver'   => 'session',
            'provider' => 'administrators',
        ],

        'api' => [
            'driver'   => 'sanctum',
            'provider' => 'administrators',
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | User Providers
    |--------------------------------------------------------------------------
    | Two providers — one per authenticatable model.
    | Sanctum will resolve tokens for whichever model issued them.
    |--------------------------------------------------------------------------
    */

    'providers' => [
        'administrators' => [
            'driver' => 'eloquent',
            'model'  => App\Models\Administrator::class,
        ],

        'caregivers' => [
            'driver' => 'eloquent',
            'model'  => App\Models\Caregiver::class,
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Password Reset
    |--------------------------------------------------------------------------
    */

    'passwords' => [
        'administrators' => [
            'provider' => 'administrators',
            'table'    => 'password_reset_tokens',
            'expire'   => 60,
            'throttle' => 60,
        ],
    ],

    'password_timeout' => 10800,

];
