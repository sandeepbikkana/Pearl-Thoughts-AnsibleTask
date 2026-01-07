CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  name TEXT,
  email TEXT
);

INSERT INTO customers (name, email)
VALUES ('Charlie', 'charlie@example.com'),
       ('Diana', 'diana@example.com');
