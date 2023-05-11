INSERT INTO address (street, house_number, floor)
VALUES
    ('Абая', 12, 3),
    ('Аль-Фараби', 45, 2),
    ('Достык', 78, 1),
    ('Толе би', 10, 5);

INSERT INTO city (name)
VALUES
    ('Алматы'),
    ('Нур-Султан'),
    ('Актау'),
    ('Шымкент');

INSERT INTO "user" (first_name, last_name, email, phone, gender, birth_date, password, city_id)
VALUES
    ('Айгерим', 'Казбекова', 'aigerim.k@gmail.com', '87771234567', 'FEMALE', '1995-02-03', 'password1', 1),
    ('Еркежан', 'Смагулова', 'erkesh.sm@gmail.com', '87779876543', 'FEMALE', '1998-06-15', 'password2', 2),
    ('Айбек', 'Сарыбаев', 'aibek.saribaev@gmail.com', '87779998877', 'MALE', '1990-11-23', 'password3', 3),
    ('Дана', 'Алтынбаева', 'dana.altynbaeva@gmail.com', '87775553333', 'FEMALE', '1992-04-20', 'password4', 4);

INSERT INTO user_address (user_id, address_id)
VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4);

INSERT INTO store (address, open_from, open_to, city_id)
VALUES ('Abay', '08:00:00', '20:00:00', 1),
('Saryarka', '09:00:00', '21:00:00', 2),
('Shakarim', '10:00:00', '22:00:00', 3);

INSERT INTO category (title, parent_id)
VALUES ('Electronics', NULL),
('Phones', 1),
('Computers', 1),
('Laptops', 3),
('Desktops', 3);

INSERT INTO product (title, description, full_description, price, rating_score, category_id)
VALUES ('iPhone 13', 'A new generation of iPhone', 'The iPhone 13 is the latest smartphone from Apple', 1000, 4.5, 2),
('MacBook Pro', 'Powerful laptop from Apple', 'The MacBook Pro is a high-end laptop with top-of-the-line specs', 2000, 4.8, 4),
('Samsung Galaxy S21', 'Flagship smartphone from Samsung', 'The Galaxy S21 is a top-of-the-line Android smartphone', 900, 4.3, 2),
('HP Pavilion', 'Affordable laptop from HP', 'The HP Pavilion is a great laptop for everyday use', 800, 4.0, 5);

INSERT INTO store_inventory (store_id, product_id, quantity) VALUES
(1, 1, 10),
(1, 2, 5),
(1, 3, 2),
(2, 1, 20),
(2, 2, 8),
(3, 3, 4);

INSERT INTO "order" (user_id, order_date, delivery_date, total_price, status, order_type, refund_reason, address_id, income_order_id) VALUES
(1, '2023-05-12', '2023-05-15', 200, 'PENDING', 'INCOME', NULL, 1, NULL),
(2, '2023-05-12', '2023-05-13', 300, 'DELIVERED', 'INCOME', NULL, 2, NULL),
(1, '2023-05-11', '2023-05-14', 150, 'CANCELED', 'REFUND', 'Wrong address', 3, 1),
(3, '2023-05-10', '2023-05-14', 250, 'IN_PROCESS', 'INCOME', NULL, 4, NULL);

INSERT INTO order_product (order_id, product_id, store_id, quantity) VALUES
(1, 1, 1, 2),
(1, 2, 1, 3),
(2, 1, 1, 1),
(2, 3, 1, 2),
(3, 2, 1, 1),
(4, 3, 1, 3),
(4, 4, 1, 1);

INSERT INTO payment_transaction (order_id, payment_method, payment_platform, amount, status) VALUES
(1, 'CASH', NULL, 200, 'SUCCESS'),
(2, 'CREDIT_CARD', 'VISA', 300, 'SUCCESS'),
(3, 'CREDIT', 'Kaspi', 150, 'FAIL'),
(4, 'CASH', NULL, 250, 'PENDING');

INSERT INTO product_review (review, rating, user_id, product_id) VALUES
('Это отличный продукт!', 4.5, 1, 1),
('Я очень доволен своей покупкой', 5, 2, 1),
('Мог бы быть лучше', 3, 1, 2),
('Удивительный продукт! Очень рекомендую', 5, 3, 3),
('Не то, что я ожидал', 2.5, 2, 4);