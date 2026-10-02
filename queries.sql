USE library_db;

-- 1. All books with their authors
SELECT b.title, a.name AS author, b.genre, b.published_year
FROM books b
JOIN authors a ON a.author_id = b.author_id
ORDER BY b.title;

-- 2. Books currently checked out (uses the view)
SELECT * FROM current_loans;

-- 3. Available copies per book
SELECT b.title,
       b.copies_total - COUNT(l.loan_id) AS copies_available
FROM books b
LEFT JOIN loans l ON l.book_id = b.book_id AND l.return_date IS NULL
GROUP BY b.book_id, b.title, b.copies_total;

-- 4. Overdue books (not returned and past due date)
SELECT m.full_name, b.title, l.due_date,
       DATEDIFF(CURDATE(), l.due_date) AS days_overdue
FROM loans l
JOIN members m ON m.member_id = l.member_id
JOIN books b   ON b.book_id = l.book_id
WHERE l.return_date IS NULL AND l.due_date < CURDATE();

-- 5. Most borrowed books
SELECT b.title, COUNT(*) AS times_borrowed
FROM loans l
JOIN books b ON b.book_id = l.book_id
GROUP BY b.book_id, b.title
ORDER BY times_borrowed DESC;

-- 6. Members who have never borrowed a book
SELECT m.full_name
FROM members m
LEFT JOIN loans l ON l.member_id = m.member_id
WHERE l.loan_id IS NULL;

-- 7. Number of books per author
SELECT a.name, COUNT(b.book_id) AS total_books
FROM authors a
LEFT JOIN books b ON b.author_id = a.author_id
GROUP BY a.author_id, a.name;

-- 8. Late returns (returned after due date)
SELECT m.full_name, b.title, l.due_date, l.return_date
FROM loans l
JOIN members m ON m.member_id = l.member_id
JOIN books b   ON b.book_id = l.book_id
WHERE l.return_date > l.due_date;
