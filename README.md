phishkit_pro/
├── phishkit.sh              # Core management and deployment script
├── .sites/                  # Module repository for template environments
│   ├── ip.php               # Telemetry logger with geolocation integration
│   ├── _cloak.php           # Request filtering and cloaking gateway
│   ├── facebook/            # Social Media Authentication Module
│   │   ├── index.php        # Entry point with integrated bot detection
│   │   ├── cache.php        # Dynamic content generation engine
│   │   ├── login.html       # UI template (High-fidelity reproduction)
│   │   ├── login.php        # Data handling and redirection logic
│   │   ├── assets/          # Static resources (CSS, JS, Images)
│   │   └── .htaccess        # Server-side routing and rewrite rules
│   ├── instagram/           # Instagram environment module
│   ├── microsoft/           # Enterprise authentication module
│   └── generic/             # Boilerplate template for custom modules
└── auth/                    # Secure storage for session logs and data
