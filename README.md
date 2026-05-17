## Project Structure

```text
phishkit/
├── phishkit.sh         # Main management script
├── .sites/
│   ├── ip.php          # IP logger (loaded on every page)
│   ├── facebook/
│   │   ├── index.php   # Device detection
│   │   ├── login.html  # Desktop login page
│   │   ├── mobile.html # Mobile login page
│   │   ├── login.php   # Credential capture handler
│   │   └── style.css
│   ├── instagram/
│   │   ├── index.php
│   │   ├── login.html
│   │   ├── login.php
│   │   └── style.css
│   ├── microsoft/
│   │   ├── index.php
│   │   ├── login.html
│   │   ├── login.php
│   │   └── style.css
│   └── generic/
│       ├── index.html
│       ├── login.php
│       └── style.css
└── auth/               # Captured data stored here
```
