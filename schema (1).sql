-- Library Management System: schema
DROP DATABASE IF EXISTS library_db;
CREATE DATABASE library_db;
USE library_db;

CREATE TABLE authors (
    author_id   INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    country     VARCHAR(50)
);

CREATE TABLE books (
    book_id       INT AUTO_INCREMENT PRIMARY KEY,
    title         VARCHAR(150) NOT NULL,
    author_id     INT NOT NULL,
    genre         VARCHAR(50),
    published_year INT,
    copies_total  INT NOT NULL DEFAULT 1 CHECK (copies_total >= 0),
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

CREATE TABLE members (
    member_id   INT AUTO_INCREMENT PRIMARY KEY,
    full_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(100) UNIQUE NOT NULL,
    join_date   DATE NOT NULL
);

CREATE TABLE loans (
    loan_id      INT AUTO_INCREMENT PRIMARY KEY,
    book_id      INT NOT NULL,
    member_id    INT NOT NULL,
    loan_date    DATE NOT NULL,
    due_date     DATE NOT NULL,
    return_date  DATE,
    FOREIGN KEY (book_id)   REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

-- View: books currently checked out
CREATE VIEW current_loans AS
SELECT l.loan_id, b.title, m.full_name, l.loan_date, l.due_date
FROM loans l
JOIN books b   ON b.book_id = l.book_id
JOIN members m ON m.member_id = l.member_id
WHERE l.return_date IS NULL;
