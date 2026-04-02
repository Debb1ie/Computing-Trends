<?php
/**
 * Computing Trends Seminar — PUP CCIS Sta. Mesa
 * Backend API (PHP 8.1+)
 * File: api.php
 *
 * Endpoints:
 *   POST /api.php?action=register   — Submit seminar registration
 *   POST /api.php?action=contact    — Submit contact message
 *   GET  /api.php?action=events     — Fetch all upcoming events
 *   GET  /api.php?action=program&event_id=1  — Fetch program flow
 *   GET  /api.php?action=speakers&event_id=1 — Fetch speakers
 *   GET  /api.php?action=faqs       — Fetch FAQs
 */

// ── CORS & Content-Type ───────────────────────────────────────
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(204); exit; }

// ── DB Config ─────────────────────────────────────────────────
define('DB_HOST', 'localhost');
define('DB_NAME', 'computing_trends_db');
define('DB_USER', 'root');       // ← change to your DB user
define('DB_PASS', '');           // ← change to your DB password
define('DB_CHARSET', 'utf8mb4');

function db(): PDO {
    static $pdo = null;
    if ($pdo === null) {
        $dsn = sprintf('mysql:host=%s;dbname=%s;charset=%s', DB_HOST, DB_NAME, DB_CHARSET);
        $pdo = new PDO($dsn, DB_USER, DB_PASS, [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]);
    }
    return $pdo;
}

function json_ok(mixed $data, string $message = 'OK'): never {
    echo json_encode(['status' => 'ok', 'message' => $message, 'data' => $data]);
    exit;
}

function json_err(string $message, int $code = 400): never {
    http_response_code($code);
    echo json_encode(['status' => 'error', 'message' => $message, 'data' => null]);
    exit;
}

function generate_ref(): string {
    return strtoupper(substr(md5(uniqid('CT', true)), 0, 8));
}

// ── Router ────────────────────────────────────────────────────
$action = $_GET['action'] ?? '';

match ($action) {
    'events'    => handle_events(),
    'program'   => handle_program(),
    'speakers'  => handle_speakers(),
    'faqs'      => handle_faqs(),
    'register'  => handle_register(),
    'contact'   => handle_contact(),
    default     => json_err('Unknown action', 404),
};

// ── Handlers ──────────────────────────────────────────────────

function handle_events(): void {
    $rows = db()->query(
        "SELECT id, title, slug, description, event_date, start_time, end_time,
                venue, mode, capacity, seats_taken, status
         FROM events
         ORDER BY event_date ASC"
    )->fetchAll();
    json_ok($rows);
}

function handle_program(): void {
    $event_id = (int)($_GET['event_id'] ?? 1);
    $stmt = db()->prepare(
        "SELECT time_start, time_end, title, description, type, room, sort_order
         FROM program_flow
         WHERE event_id = ?
         ORDER BY sort_order ASC"
    );
    $stmt->execute([$event_id]);
    json_ok($stmt->fetchAll());
}

function handle_speakers(): void {
    $event_id = (int)($_GET['event_id'] ?? 1);
    $stmt = db()->prepare(
        "SELECT s.id, s.full_name, s.title, s.organization, s.bio,
                s.expertise, s.is_featured, es.role, es.topic
         FROM speakers s
         JOIN event_speakers es ON es.speaker_id = s.id
         WHERE es.event_id = ?
         ORDER BY s.is_featured DESC, s.full_name ASC"
    );
    $stmt->execute([$event_id]);
    json_ok($stmt->fetchAll());
}

function handle_faqs(): void {
    $rows = db()->query(
        "SELECT question, answer FROM faqs
         WHERE is_active = 1 ORDER BY sort_order ASC"
    )->fetchAll();
    json_ok($rows);
}

function handle_register(): void {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') json_err('POST required', 405);
    $body = json_decode(file_get_contents('php://input'), true) ?? [];

    // Validate required fields
    $required = ['first_name','last_name','email','event_id'];
    foreach ($required as $f) {
        if (empty($body[$f])) json_err("Field '{$f}' is required.");
    }

    $email    = filter_var(trim($body['email']), FILTER_VALIDATE_EMAIL);
    if (!$email) json_err('Invalid email address.');

    $event_id = (int)$body['event_id'];

    // Check event capacity
    $pdo  = db();
    $event = $pdo->prepare("SELECT capacity, seats_taken, status, title FROM events WHERE id = ?");
    $event->execute([$event_id]);
    $ev = $event->fetch();
    if (!$ev) json_err('Event not found.', 404);
    if ($ev['status'] === 'cancelled') json_err('This event has been cancelled.');
    if ($ev['seats_taken'] >= $ev['capacity']) json_err('Sorry, this event is fully booked.');

    // Check duplicate
    $dup = $pdo->prepare("SELECT id FROM registrations WHERE event_id = ? AND email = ?");
    $dup->execute([$event_id, $email]);
    if ($dup->fetch()) json_err('This email is already registered for this event.');

    // Generate unique ref
    do { $ref = generate_ref(); }
    while ($pdo->prepare("SELECT id FROM registrations WHERE ref_code = ?")->execute([$ref]) &&
           $pdo->query("SELECT FOUND_ROWS()")->fetchColumn() > 0);

    $ins = $pdo->prepare(
        "INSERT INTO registrations
         (event_id, ref_code, first_name, last_name, email, student_id,
          year_section, course, role, affiliation, expectations, status)
         VALUES (?,?,?,?,?,?,?,?,?,?,?,'pending')"
    );
    $ins->execute([
        $event_id,
        $ref,
        trim($body['first_name']),
        trim($body['last_name']),
        $email,
        trim($body['student_id']   ?? ''),
        trim($body['year_section'] ?? ''),
        trim($body['course']       ?? ''),
        $body['role']              ?? 'student',
        trim($body['affiliation']  ?? ''),
        trim($body['expectations'] ?? ''),
    ]);

    // Increment seat count
    $pdo->prepare("UPDATE events SET seats_taken = seats_taken + 1 WHERE id = ?")->execute([$event_id]);

    json_ok([
        'ref_code'   => $ref,
        'event_name' => $ev['title'],
        'email'      => $email,
    ], "Registration successful! Your reference code is {$ref}.");
}

function handle_contact(): void {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') json_err('POST required', 405);
    $body = json_decode(file_get_contents('php://input'), true) ?? [];

    $required = ['full_name','email','subject','message'];
    foreach ($required as $f) {
        if (empty($body[$f])) json_err("Field '{$f}' is required.");
    }
    $email = filter_var(trim($body['email']), FILTER_VALIDATE_EMAIL);
    if (!$email) json_err('Invalid email address.');

    db()->prepare(
        "INSERT INTO contact_messages (full_name, email, subject, message)
         VALUES (?,?,?,?)"
    )->execute([
        trim($body['full_name']),
        $email,
        trim($body['subject']),
        trim($body['message']),
    ]);

    json_ok([], 'Message received. We\'ll get back to you within 2 business days.');
}
