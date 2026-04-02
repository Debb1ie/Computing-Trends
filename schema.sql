-- ============================================================
--  COMPUTING TRENDS SEMINAR — PUP CCIS Sta. Mesa
--  Database Schema
--  Engine: MySQL 8.0+ / MariaDB 10.6+
-- ============================================================

CREATE DATABASE IF NOT EXISTS computing_trends_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE computing_trends_db;

-- ────────────────────────────────────────────────────────────
-- 1. EVENTS
-- ────────────────────────────────────────────────────────────
CREATE TABLE events (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title         VARCHAR(200)  NOT NULL,
  slug          VARCHAR(200)  NOT NULL UNIQUE,
  description   TEXT,
  long_desc     LONGTEXT,
  event_date    DATE          NOT NULL,
  start_time    TIME          NOT NULL,
  end_time      TIME,
  venue         VARCHAR(300)  NOT NULL,
  mode          ENUM('in-person','online','hybrid') NOT NULL DEFAULT 'in-person',
  capacity      SMALLINT UNSIGNED NOT NULL DEFAULT 100,
  seats_taken   SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  status        ENUM('upcoming','ongoing','completed','cancelled') NOT NULL DEFAULT 'upcoming',
  cover_image   VARCHAR(500),
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_status  (status),
  INDEX idx_date    (event_date)
) ENGINE=InnoDB;

-- ────────────────────────────────────────────────────────────
-- 2. PROGRAM FLOW / AGENDA
-- ────────────────────────────────────────────────────────────
CREATE TABLE program_flow (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  event_id    INT UNSIGNED NOT NULL,
  time_start  TIME         NOT NULL,
  time_end    TIME,
  title       VARCHAR(200) NOT NULL,
  description TEXT,
  type        ENUM('keynote','talk','panel','workshop','break','activity','ceremony') NOT NULL DEFAULT 'talk',
  room        VARCHAR(100),
  sort_order  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
  INDEX idx_event (event_id)
) ENGINE=InnoDB;

-- ────────────────────────────────────────────────────────────
-- 3. SPEAKERS
-- ────────────────────────────────────────────────────────────
CREATE TABLE speakers (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  full_name    VARCHAR(150) NOT NULL,
  title        VARCHAR(200),
  organization VARCHAR(200),
  bio          TEXT,
  photo_url    VARCHAR(500),
  email        VARCHAR(150),
  linkedin_url VARCHAR(300),
  expertise    VARCHAR(500),        -- comma-separated tags
  is_featured  TINYINT(1) NOT NULL DEFAULT 0,
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Link speakers to events
CREATE TABLE event_speakers (
  event_id    INT UNSIGNED NOT NULL,
  speaker_id  INT UNSIGNED NOT NULL,
  role        ENUM('keynote','speaker','panelist','moderator','facilitator') DEFAULT 'speaker',
  topic       VARCHAR(300),
  PRIMARY KEY (event_id, speaker_id),
  FOREIGN KEY (event_id)   REFERENCES events(id)   ON DELETE CASCADE,
  FOREIGN KEY (speaker_id) REFERENCES speakers(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ────────────────────────────────────────────────────────────
-- 4. REGISTRATIONS
-- ────────────────────────────────────────────────────────────
CREATE TABLE registrations (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  event_id        INT UNSIGNED NOT NULL,
  ref_code        CHAR(10)     NOT NULL UNIQUE,
  first_name      VARCHAR(80)  NOT NULL,
  last_name       VARCHAR(80)  NOT NULL,
  email           VARCHAR(150) NOT NULL,
  student_id      VARCHAR(30),
  year_section    VARCHAR(30),
  course          VARCHAR(100),
  role            ENUM('student','faculty','industry','alumni','guest') NOT NULL DEFAULT 'student',
  affiliation     VARCHAR(200),
  expectations    TEXT,
  dietary_needs   VARCHAR(200),
  status          ENUM('pending','confirmed','cancelled','attended') NOT NULL DEFAULT 'pending',
  registered_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  confirmed_at    TIMESTAMP NULL,
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE RESTRICT,
  INDEX idx_event  (event_id),
  INDEX idx_email  (email),
  INDEX idx_ref    (ref_code)
) ENGINE=InnoDB;

-- ────────────────────────────────────────────────────────────
-- 5. CONTACT MESSAGES
-- ────────────────────────────────────────────────────────────
CREATE TABLE contact_messages (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  full_name   VARCHAR(150) NOT NULL,
  email       VARCHAR(150) NOT NULL,
  subject     VARCHAR(300) NOT NULL,
  message     TEXT         NOT NULL,
  is_read     TINYINT(1)   NOT NULL DEFAULT 0,
  replied_at  TIMESTAMP    NULL,
  created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_read (is_read)
) ENGINE=InnoDB;

-- ────────────────────────────────────────────────────────────
-- 6. ABOUT / TEAM MEMBERS
-- ────────────────────────────────────────────────────────────
CREATE TABLE team_members (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  full_name   VARCHAR(150) NOT NULL,
  role        VARCHAR(200) NOT NULL,
  photo_url   VARCHAR(500),
  bio         TEXT,
  sort_order  TINYINT UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB;

-- ────────────────────────────────────────────────────────────
-- 7. FAQ
-- ────────────────────────────────────────────────────────────
CREATE TABLE faqs (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  question    VARCHAR(500) NOT NULL,
  answer      TEXT         NOT NULL,
  sort_order  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  is_active   TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB;

-- ============================================================
--  SEED DATA
-- ============================================================

-- Events
INSERT INTO events
  (title, slug, description, long_desc, event_date, start_time, end_time, venue, mode, capacity, status)
VALUES
(
  'Computing Trends 2025: The AI-Driven Future',
  'computing-trends-2025',
  'A flagship seminar by CCIS PUP Sta. Mesa exploring the forefront of computing — from generative AI to quantum computing.',
  'Join us for a day-long immersive seminar where thought leaders, industry practitioners, and academics converge to discuss the transformative computing trends shaping our world. Topics include large language models, edge computing, cybersecurity in the AI era, quantum supremacy, and the future of software engineering. This event is open to all BS Computer Science, BS Information Technology, and BS Computer Engineering students and faculty.',
  '2025-06-14',
  '08:00:00',
  '17:00:00',
  'PUP Moro Lorenzo Sports Center / Main Auditorium, Sta. Mesa, Manila',
  'hybrid',
  300,
  'upcoming'
),
(
  'Computing Trends Workshop: Hands-On with Generative AI',
  'computing-trends-workshop-genai',
  'A focused half-day workshop on building with LLMs, prompt engineering, and deploying AI-powered applications.',
  'Roll up your sleeves for this hands-on session. Participants will build a fully functional AI-powered app using open-source LLMs, learn prompt engineering patterns, and explore the architecture of modern generative AI systems. Laptops required.',
  '2025-07-05',
  '13:00:00',
  '17:00:00',
  'CCIS Computer Laboratory, PUP Sta. Mesa',
  'in-person',
  40,
  'upcoming'
),
(
  'Computing Trends Forum: Ethics & Governance in Tech',
  'computing-trends-ethics-forum',
  'A panel discussion on responsible AI, data privacy, algorithmic bias, and the policy landscape for emerging technologies.',
  'Technology reshapes society faster than policy can respond. This forum gathers legal experts, ethicists, and technologists to discuss the pressing questions: Who owns your data? How do we audit AI decisions? What frameworks govern autonomous systems? Open to all, no technical background required.',
  '2025-08-22',
  '09:00:00',
  '12:00:00',
  'Online via Zoom',
  'online',
  500,
  'upcoming'
);

-- Program Flow for Event 1
INSERT INTO program_flow
  (event_id, time_start, time_end, title, description, type, room, sort_order)
VALUES
(1,'07:30:00','08:00:00','Registration & Kit Distribution','Sign-in, collect your seminar kit and ID lace','activity','Main Lobby',1),
(1,'08:00:00','08:20:00','Opening Ceremony','National Anthem, Prayer, Welcome Remarks by the Dean of CCIS','ceremony','Main Auditorium',2),
(1,'08:20:00','08:40:00','PUP CCIS Overview & Vision 2030','College presentation and roadmap by the CCIS Department Chair','talk','Main Auditorium',3),
(1,'08:40:00','09:30:00','Keynote: The Age of Generative AI','Industry keynote exploring how LLMs are reshaping software engineering, research, and creative industries','keynote','Main Auditorium',4),
(1,'09:30:00','10:00:00','Talk: Quantum Computing — From Theory to Practice','Introduction to quantum algorithms and near-term applications in cryptography and optimization','talk','Main Auditorium',5),
(1,'10:00:00','10:15:00','Coffee Break & Networking','Light refreshments provided','break','Lobby',6),
(1,'10:15:00','11:00:00','Talk: Cybersecurity in the AI Era','Evolving threats, AI-powered defense, and zero-trust architecture','talk','Main Auditorium',7),
(1,'11:00:00','11:45:00','Talk: Edge Computing & the IoT Ecosystem','From cloud to the edge — architectures for real-time intelligent systems','talk','Main Auditorium',8),
(1,'11:45:00','13:00:00','Lunch Break','Catered lunch & open networking','break','Cafeteria',9),
(1,'13:00:00','14:00:00','Workshop Breakout A: Prompt Engineering Deep Dive','Hands-on prompt crafting, chain-of-thought, RAG patterns','workshop','Lab 1',10),
(1,'13:00:00','14:00:00','Workshop Breakout B: Data Engineering with dbt & Spark','Modern data pipeline patterns','workshop','Lab 2',11),
(1,'14:00:00','15:00:00','Panel: The Future of Tech Careers & Skills Gap','Industry leaders discuss what skills will matter most in 5 years','panel','Main Auditorium',12),
(1,'15:00:00','15:15:00','Short Break','—','break','Lobby',13),
(1,'15:15:00','16:00:00','Talk: Responsible AI & Algorithmic Ethics','Bias, fairness, explainability, and governance frameworks','talk','Main Auditorium',14),
(1,'16:00:00','16:30:00','Open Q&A Forum','Live audience Q&A with all speakers','activity','Main Auditorium',15),
(1,'16:30:00','17:00:00','Awarding & Closing Ceremony','Certificates of participation, raffle draw, closing remarks','ceremony','Main Auditorium',16);

-- Speakers
INSERT INTO speakers
  (full_name, title, organization, bio, expertise, is_featured)
VALUES
('Dr. Maria Santos','Dean, College of Computing & Information Sciences','PUP Sta. Mesa','Dr. Santos has led CCIS through a decade of academic innovation. Her research focuses on machine learning applications in education and public administration.','AI in Education,Institutional Leadership,Research',1),
('Engr. Carlo Reyes','Lead AI Engineer','Thinking Machines Data Science','Carlo has deployed ML systems at scale for government and enterprise clients across Southeast Asia. A PUP alumni turned industry leader.','Machine Learning,MLOps,LLMs',1),
('Prof. Ana Dela Cruz','Associate Professor, CCIS','PUP Sta. Mesa','An expert in cybersecurity and network systems, Prof. Dela Cruz has published extensively on AI-driven intrusion detection and digital forensics.','Cybersecurity,Network Systems,Digital Forensics',1),
('Mr. Jose Bautista','CTO & Co-Founder','TechBridge PH','Jose bootstrapped TechBridge from a dormitory project to a 120-person tech company. He speaks on startup culture, product engineering, and the Philippine tech ecosystem.','Startups,Product Engineering,Entrepreneurship',1),
('Dr. Rina Villanueva','Quantum Computing Researcher','DOST-ASTI','Dr. Villanueva leads quantum computing initiatives at DOST. Her work bridges academic research and national technology strategy.','Quantum Computing,Cryptography,Science Policy',0),
('Ms. Trisha Lim','Data Privacy Officer','Bangko Sentral ng Pilipinas','With expertise in RA 10173 and GDPR compliance, Trisha helps organizations build privacy-first data strategies.','Data Privacy,Regulatory Compliance,Governance',0);

-- Event-Speaker links (Event 1)
INSERT INTO event_speakers (event_id, speaker_id, role, topic) VALUES
(1,1,'moderator','Opening & Closing Ceremonies'),
(1,2,'keynote','The Age of Generative AI'),
(1,3,'speaker','Cybersecurity in the AI Era'),
(1,4,'panelist','Future of Tech Careers'),
(1,5,'speaker','Quantum Computing — From Theory to Practice'),
(1,6,'panelist','Responsible AI & Algorithmic Ethics');

-- Event-Speaker links (Event 2)
INSERT INTO event_speakers (event_id, speaker_id, role, topic) VALUES
(2,2,'facilitator','Hands-On with Generative AI'),
(2,4,'facilitator','Prompt Engineering Patterns');

-- Team Members
INSERT INTO team_members (full_name, role, sort_order) VALUES
('Dr. Maria Santos','Dean, CCIS — Event Patron',1),
('Prof. Ana Dela Cruz','Event Adviser',2),
('Juan Dela Cruz','Event Coordinator',3),
('Kristine Bautista','Logistics Head',4),
('Paolo Ramos','Multimedia & Design',5),
('Mia Torres','Registration & Documentation',6);

-- FAQs
INSERT INTO faqs (question, answer, sort_order) VALUES
('Who can attend the Computing Trends Seminar?','The seminar is primarily for CCIS students and faculty of PUP Sta. Mesa, but is also open to students from other colleges, industry professionals, and alumni.',1),
('Is there a registration fee?','The main seminar event is FREE for all PUP students with valid school ID. Industry participants and external guests may have a minimal fee. Specific workshop sessions may have separate fees.',2),
('Will certificates be issued?','Yes! E-certificates of participation will be sent to all registered attendees who complete the event. Physical certificates will be available for in-person attendees.',3),
('Is the event available online?','Yes. The main seminar follows a hybrid format — you can join via the Zoom link provided upon registration.',4),
('Can I suggest a topic or speaker?','Absolutely. Reach out to us via the Contact section with your suggestion. We review all submissions for future events.',5);
