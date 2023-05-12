-- Check last status of order
CREATE OR REPLACE FUNCTION get_order_status(orderID INTEGER) RETURNS VARCHAR(50) AS $$
DECLARE
    order_status VARCHAR(50);
BEGIN
    SELECT status INTO order_status FROM "order" WHERE order_id = orderID;
    RETURN order_status;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE EXCEPTION 'Order % does not exist', orderID;
END;
$$ LANGUAGE plpgsql;

select * from get_order_status(1);

-- Function to retrieve all products in a given store
CREATE FUNCTION get_products_in_store(storeID INT)
RETURNS TABLE(product_id INT, title VARCHAR, description VARCHAR, price INT)
AS $$
BEGIN
  RETURN QUERY
    SELECT p.product_id, p.title, p.description, p.price
    FROM product p
    INNER JOIN store_inventory si ON p.product_id = si.product_id
    WHERE si.store_id = storeID;
END;
$$ LANGUAGE plpgsql;

select * from get_products_in_store(1);

-- Function to calculate the total price of an order:
CREATE FUNCTION calculate_total_price(orderID INT)
RETURNS INT
AS $$
DECLARE
  total INT := 0;
BEGIN
  SELECT SUM(p.price * op.quantity)
  INTO total
  FROM product p
  INNER JOIN order_product op ON p.product_id = op.product_id
  WHERE op.order_id = orderID;

  RETURN total;
END;
$$ LANGUAGE plpgsql;

select * from calculate_total_price(1);

-- If we pay for the order with bonuses, we must deduct this from the total_price
CREATE OR REPLACE PROCEDURE apply_bonus(IN p_order_id INTEGER, IN p_bonus_amount INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
  v_order_total INTEGER;
BEGIN
  SELECT total_price INTO v_order_total FROM "order" WHERE order_id = p_order_id;

  IF p_bonus_amount <= 0 OR p_bonus_amount > (SELECT bonus_amount FROM "user" WHERE user_id = (SELECT user_id FROM "order" WHERE order_id = p_order_id)) THEN
    RAISE EXCEPTION 'Invalid bonus amount';
  END IF;

  IF v_order_total <= p_bonus_amount THEN
    RAISE EXCEPTION 'Bonus amount cannot be greater than or equal to the order total';
  END IF;

  UPDATE "order"
  SET total_price = v_order_total - p_bonus_amount
  WHERE order_id = p_order_id;

  UPDATE "user"
  SET bonus_amount = bonus_amount - p_bonus_amount
  WHERE user_id = (SELECT user_id FROM "order" WHERE order_id = p_order_id);
END;
$$;

CALL apply_bonus(1, 2);

-- Detect recursively parent categories
CREATE OR REPLACE FUNCTION get_parent_categories(parentID INT)
RETURNS TABLE(category_id INT, title VARCHAR, parent_id int) AS $$
BEGIN
    RETURN QUERY WITH RECURSIVE parent_categories AS (
	SELECT category.category_id, category.title, category.parent_id FROM category
	WHERE category.category_id = parentID
	UNION
		SELECT c.category_id, c.title, c.parent_id FROM category c
		INNER JOIN parent_categories s ON s.parent_id = c.category_id
) SELECT * FROM parent_categories;
END;
$$ LANGUAGE plpgsql;
select * from get_parent_categories(5);
