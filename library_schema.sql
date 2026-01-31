-- ============================================================
-- Library Management System - SQLite Database
-- Run this entire file in DB Browser for SQLite (Execute SQL).
-- ============================================================

-- Enable foreign key enforcement (SQLite keeps it OFF by default)
PRAGMA foreign_keys = ON;

-- ------------------------------------------------------------
-- SECTION 1: DROP EXISTING TABLES
-- Order: drop child tables first (borrowed_books), then parents.
-- ------------------------------------------------------------
DROP TABLE IF EXISTS borrowed_books;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS users;

-- ------------------------------------------------------------
-- SECTION 2: CREATE TABLES
-- Order: parent tables first (users), then children (members, books, borrowed_books).
-- ------------------------------------------------------------

-- 2.1 Users: login and role (librarian, member, etc.)
CREATE TABLE users (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT    NOT NULL,
    password    TEXT    NOT NULL,
    role        TEXT    NOT NULL
);

-- 2.2 Members: library members with balance (member_id must exist in users)
CREATE TABLE members (
    member_id   INTEGER PRIMARY KEY,
    balance     REAL    NOT NULL DEFAULT 0,
    FOREIGN KEY (member_id) REFERENCES users(id)
);

-- 2.3 Books: catalogue with availability and optional cover (TEXT = file path, not BLOB)
CREATE TABLE books (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    title       TEXT    NOT NULL,
    author      TEXT    NOT NULL,
    available   INTEGER NOT NULL DEFAULT 1,
    cover_path  TEXT
);

-- For existing DBs: add cover column without recreating the table
-- ALTER TABLE books ADD COLUMN cover_path TEXT;

-- 2.4 Borrowed books: links member, book, borrow_date, return_date
CREATE TABLE borrowed_books (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    member_id   INTEGER NOT NULL,
    book_id     INTEGER NOT NULL,
    borrow_date TEXT    NOT NULL,
    return_date TEXT,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(id)
);

-- ------------------------------------------------------------
-- SECTION 3: INSERT SAMPLE DATA
-- Order: must match foreign keys (users before members; books before borrowed_books).
-- ------------------------------------------------------------

-- 3.1 Users (ids will be 1, 2, 3)
INSERT INTO users (name, password, role) VALUES
    ('admin', 'admin123', 'librarian'),
    ('john_doe', 'pass123', 'member'),
    ('jane_smith', 'pass456', 'member');

-- 3.2 Members (member_id 2 and 3 refer to users 2 and 3)
INSERT INTO members (member_id, balance) VALUES
    (2, 0.00),
    (3, 5.50);

-- 3.3 Books (ids 1, 2, 3, 4; all available)
INSERT INTO books (title, author, available) VALUES
    ('Introduction to Algorithms', 'Cormen et al.', 1),
    ('Clean Code', 'Robert Martin', 1),
    ('Database Systems', 'Silberschatz', 1),
    ('Software Engineering', 'Ian Sommerville', 1);

-- 3.4 One borrowed record: member 2 borrowed book 1, not yet returned
INSERT INTO borrowed_books (member_id, book_id, borrow_date, return_date) VALUES
    (2, 1, date('now', '-7 days'), NULL);

-- 3.5 Keep books.available in sync: book 1 is out
UPDATE books SET available = 0 WHERE id = 1;

-- ------------------------------------------------------------
-- SECTION 4: QUERIES (read-only; safe to run with the whole file)
-- ------------------------------------------------------------

-- 4.1 Query all available books
SELECT id, title, author
FROM books
WHERE available = 1;

-- 4.2 Query borrowed books by member (e.g. member_id = 2)
SELECT bb.id, b.title, b.author, bb.borrow_date, bb.return_date
FROM borrowed_books bb
JOIN books b ON bb.book_id = b.id
WHERE bb.member_id = 2;

-- 4.3 Only currently borrowed by member (return_date IS NULL)
SELECT bb.id, b.title, b.author, bb.borrow_date
FROM borrowed_books bb
JOIN books b ON bb.book_id = b.id
WHERE bb.member_id = 2 AND bb.return_date IS NULL;

-- ------------------------------------------------------------
-- SECTION 5: BORROW / RETURN (run these separately when needed)
-- Do NOT run 5.1 and 5.2 together for the same book in one go.
-- ------------------------------------------------------------

-- 5.1 BORROW A BOOK (example: member 3 borrows book 2)
-- Run these two statements together:
/*
INSERT INTO borrowed_books (member_id, book_id, borrow_date, return_date)
VALUES (3, 2, date('now'), NULL);
UPDATE books SET available = 0 WHERE id = 2;
*/

-- 5.2 RETURN A BOOK (example: return book 2)
-- Run these two statements together:
/*
UPDATE borrowed_books SET return_date = date('now') WHERE book_id = 2 AND return_date IS NULL;
UPDATE books SET available = 1 WHERE id = 2;
*/
