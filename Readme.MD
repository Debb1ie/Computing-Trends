# Computing Trends 2025 — PUP CCIS Sta. Mesa
## Website Setup & Documentation!

---

##  Project Structure!

```
computing-trends/
├── index.html          ← Main website (all sections, fully functional)
├── api.php             ← PHP REST API backend
├── README.md           ← This file
└── db/
    └── schema.sql      ← Full MySQL database schema + seed data
```

---

##  Quick Start (Local Development)

### Option A — Just the HTML (no backend)
Open `index.html` directly in a browser. All UI, navigation, program flow, FAQ accordion, and form validation work without a server.

### Option B — Full Stack (PHP + MySQL)

#### 1. Requirements
- PHP 8.1+
- MySQL 8.0+ or MariaDB 10.6+
- Web server: Apache (XAMPP/WAMP) or Nginx

#### 2. Database Setup
```sql
-- In MySQL Workbench or CLI:
mysql -u root -p < db/schema.sql
```
This creates the `computing_trends_db` database with all tables and seed data.

#### 3. Configure the API
Edit `api.php` lines 28–31:
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'computing_trends_db');
define('DB_USER', 'your_db_user');
define('DB_PASS', 'your_db_password');
```

#### 4. Enable Backend in index.html
In `index.html`, find the two commented sections marked:
```
/* === Uncomment to connect to PHP backend === */
```
Uncomment those `fetch()` blocks and comment out the demo code above them.

#### 5. Deploy
Place all files in your web server root (e.g., `htdocs/computing-trends/`) and open `http://localhost/computing-trends/`.

---

##  Database Tables

| Table | Purpose |
|---|---|
| `events` | Seminar events (title, date, venue, capacity) |
| `program_flow` | Day-of agenda / timeline items per event |
| `speakers` | Speaker profiles |
| `event_speakers` | Many-to-many: speakers ↔ events |
| `registrations` | Attendee registrations with ref codes |
| `contact_messages` | Contact form submissions |
| `team_members` | Organizing committee |
| `faqs` | FAQ entries |

---

##  API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `api.php?action=events` | List all events |
| GET | `api.php?action=program&event_id=1` | Program flow for event |
| GET | `api.php?action=speakers&event_id=1` | Speakers for event |
| GET | `api.php?action=faqs` | All FAQs |
| POST | `api.php?action=register` | Submit registration |
| POST | `api.php?action=contact` | Submit contact message |

### Registration POST body (JSON)
```json
{
  "event_id": 1,
  "first_name": "Juan",
  "last_name": "Dela Cruz",
  "email": "juan@pup.edu.ph",
  "student_id": "2021-XXXXX-MN-0",
  "course": "BS Computer Science",
  "year_section": "3-A",
  "role": "student",
  "expectations": "Learn about AI trends"
}
```

### Contact POST body (JSON)
```json
{
  "full_name": "Juan Dela Cruz",
  "email": "juan@pup.edu.ph",
  "subject": "Speaker invitation inquiry",
  "message": "Hello, I would like to propose..."
}
```

---

##  Website Sections

1. **Hero** — Event overview, date, venue, CTA buttons
2. **About CCIS** — PUP background, college pillars, stats
3. **Events** — Three event cards with seat meters and register buttons
4. **Program Flow** — Full day agenda with type filters (keynote/talk/workshop/etc.)
5. **Speakers** — Speaker cards with roles, orgs, and topic tags
6. **Register** — Full registration form with client-side validation
7. **Team** — Organizing committee grid
8. **FAQ** — Accordion-style frequently asked questions
9. **Contact** — Contact info + message form
10. **Footer** — Links, social, copyright

---

##  Design Notes

- **Color palette**: PUP Maroon (#8B1A1A) + Gold (#D4A017) on dark background
- **Fonts**: Raleway (headings) + Source Sans 3 (body)
- **Responsive**: Mobile hamburger menu, fluid grids
- **Animations**: Scroll-reveal on all sections, fade-up on hero

---

##  For Production Deployment

- Add CSRF protection to api.php forms
- Add rate limiting (e.g., `composer require symfony/rate-limiter`)
- Configure email confirmation via PHPMailer or SendGrid
- Set up SSL certificate (required for Zoom/hybrid events)
- Add admin dashboard for managing registrations

---

*Developed for Computing Trends 2025 · PUP CCIS Sta. Mesa, Manila*
