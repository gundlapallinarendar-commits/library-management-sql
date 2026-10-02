USE library_db;

INSERT INTO authors (name, country) VALUES
('George Orwell', 'UK'),
('J.K. Rowling', 'UK'),
('APJ Abdul Kalam', 'India'),
('Chetan Bhagat', 'India'),
('Paulo Coelho', 'Brazil');

INSERT INTO books (title, author_id, genre, published_year, copies_total) VALUES
('1984', 1, 'Dystopian', 1949, 3),
('Animal Farm', 1, 'Satire', 1945, 2),
('Harry Potter and the Philosopher''s Stone', 2, 'Fantasy', 1997, 4),
('Wings of Fire', 3, 'Autobiography', 1999, 3),
('Five Point Someone', 4, 'Fiction', 2004, 2),
('The Alchemist', 5, 'Fiction', 1988, 3);

INSERT INTO members (full_name, email, join_date) VALUES
('Arun Kumar', 'arun@example.com', '2026-01-10'),
('Priya Sharma', 'priya@example.com', '2026-02-15'),
('Rahul Verma', 'rahul@example.com', '2026-03-20'),
('Sneha Iyer', 'sneha@example.com', '2026-04-05');

INSERT INTO loans (book_id, member_id, loan_date, due_date, return_date) VALUES
(1, 1, '2026-09-01', '2026-09-15', '2026-09-12'),
(3, 2, '2026-09-05', '2026-09-19', NULL),
(4, 3, '2026-09-10', '2026-09-24', NULL),
(6, 1, '2026-09-20', '2026-10-04', NULL),
(2, 4, '2026-08-20', '2026-09-03', '2026-09-10'),
(1, 2, '2026-09-25', '2026-10-09', NULL);
