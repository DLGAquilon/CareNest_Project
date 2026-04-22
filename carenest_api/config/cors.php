<?php

/*
|--------------------------------------------------------------------------
| Cross-Origin Resource Sharing (CORS) Configuration
|--------------------------------------------------------------------------
| This file controls which origins, methods, and headers are allowed
| when the Laravel API receives cross-origin requests.
|
| Flutter Web runs on a random port (e.g. localhost:65395) in the browser.
| We allow all localhost origins during development.
| In production, replace '*' with your actual domain.
|
*/

return [

    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['*'],

    'allowed_origins' => ['*'],
    // For production, restrict to your domain:
    // 'allowed_origins' => ['https://carenest.yourdomain.ph'],

    'allowed_origins_patterns' => [
        // Allows any localhost port — covers Flutter web dev server
        '/^http:\/\/localhost(:\d+)?$/',
        '/^http:\/\/127\.0\.0\.1(:\d+)?$/',
    ],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => false,

];
