create or replace function is_product_available(_store_id integer, _product_id integer, _quantity integer)
returns boolean
as $$
    declare available_quantity integer;
begin
    select si.quantity into available_quantity from store_inventory si where si.store_id = _store_id and si.product_id = _product_id;
    return available_quantity >= _quantity;
end;
$$ language plpgsql;

create or replace procedure update_quantity(_order_id integer, operation char)
as $$
    declare
        r record;
begin
    if operation = '+' then
        for r in select store_id, product_id, quantity from order_product where order_id = _order_id loop
            update store_inventory
            set quantity = quantity + r.quantity where store_id = r.store_id and product_id = r.product_id;
        end loop;
    else
        for r in select store_id, product_id, quantity from order_product where order_id = _order_id loop
            update store_inventory
            set quantity = quantity - r.quantity where store_id = r.store_id and product_id = r.product_id;
        end loop;
    end if;
end;
$$ language plpgsql;

create or replace function create_order()
returns trigger
as $$
    declare payment_info record;
begin
    if new.order_type = 'REFUND' then
        if new.refund_reason is null then
            raise exception 'Refund reason is required';
        end if;
        if new.income_order_id is null then
            raise exception 'Income order id is required';
        end if;

        select payment_method, payment_platform into payment_info from payment_transaction where order_id = new.income_order_id limit 1;
    end if;
    return new;
end;
$$ language plpgsql;

create or replace function update_order()
returns trigger
as $$
begin
    if new.status = 'DELIVERED' then
        new.delivery_date := now();
    elsif new.status = 'CANCELED' then
        call update_quantity(new.order_id, '+');
    elsif new.status = 'IN_PROCESS' then
        if new.order_type = 'REFUND' then
            call update_quantity(new.order_id, '+');
        else
            call update_quantity(new.order_id, '-');
        end if;
    end if;
    return new;
end;
$$ language plpgsql;

create or replace function create_order_product()
returns trigger
as $$
    declare
        product_price integer;
        _income_order_id integer;
begin
    select price into product_price from product where product_id = new.product_id;
    if (select order_type from "order" where order_id = new.order_id) = 'INCOME' then
        if is_product_available(new.store_id, new.product_id, new.quantity) then
            update "order" set total_price = total_price + (product_price * new.quantity) where order_id = new.order_id;
        else
            raise exception 'Not enough quantity available';
        end if;
    else
        select o.income_order_id into _income_order_id from "order" o where o.order_id = new.order_id;
        if new.product_id not in (select product_id from order_product where order_id = _income_order_id) then
            raise exception 'Product not in income order';
        else
            update "order" set total_price = total_price - (product_price * new.quantity) where order_id = new.order_id;
        end if;
    end if;
    return new;
end;
$$ language plpgsql;

create or replace function update_order_product()
returns trigger
as $$
    declare
        product_price integer;
    begin
        if (select status from "order" where "order".order_id = new.order_id) != 'PENDING' then
            raise exception 'Order is not pending';
        end if;
        if old.quantity != new.quantity then
            select price into product_price from product where product_id = new.product_id;
            if new.quantity > old.quantity then
                if not is_product_available(new.store_id, new.product_id, new.quantity) then
                    raise exception 'Not enough quantity available';
                end if;
                update "order" set total_price = total_price + (product_price * (new.quantity - old.quantity)) where order_id = new.order_id;
            else
                update "order" set total_price = total_price - (product_price * (old.quantity - new.quantity)) where order_id = new.order_id;
                if new.quantity = 0 then
                    delete from order_product where order_id = new.order_id and product_id = new.product_id;
                end if;
            end if;
        end if;
        return new;
    end;
$$ language plpgsql;


create trigger order_create_trigger after insert on "order" for each row execute procedure create_order();
create trigger order_update_trigger before update on "order" for each row execute procedure update_order();
create trigger order_product_create_trigger after insert on order_product for each row execute procedure create_order_product();
create trigger order_product_update_trigger after update on order_product for each row execute procedure update_order_product(); -- ok

drop trigger order_create_trigger on "order";
drop trigger order_update_trigger on "order";
drop trigger order_product_create_trigger on order_product;
drop trigger order_product_update_trigger on order_product;

insert into "order"(user_id, order_type, address_id) values(1, 'INCOME', 1);
insert into order_product(order_id, store_id, product_id, quantity) values(4, 1, 2, 3);
insert into order_product(order_id, store_id, product_id, quantity) values(4, 1, 3, 3);

insert into "order"(user_id, order_type, address_id, refund_reason, income_order_id) values(1, 'REFUND', 1, 'test refund', 4);
insert into order_product(order_id, store_id, product_id, quantity) values(9, 1, 3, 2);

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

-- 1
-- if payment method is credit_card, we'll make a random decision to approve credit, otherwise status of transaction is success and order status is in progress
CREATE OR REPLACE FUNCTION update_payment_status()
RETURNS TRIGGER AS $$
DECLARE
    decision INTEGER;
BEGIN
    -- Generate random number 0 or 1
    decision := floor(random() * 2);

    -- Update the status of the corresponding order
    IF NEW.payment_method = 'CREDIT_CARD' THEN
        IF decision = 1 THEN
            update payment_transaction set status = 'SUCCESS' where transaction_id = NEW.transaction_id;
            UPDATE "order" SET status = 'IN_PROCESS' WHERE order_id = NEW.order_id;

        ELSE
            update payment_transaction set status = 'FAIL' where transaction_id = NEW.transaction_id;
        END IF;
    ELSE
        update payment_transaction set status = 'SUCCESS' where transaction_id = NEW.transaction_id;
        UPDATE "order" SET status = 'IN_PROCESS' WHERE order_id = NEW.order_id;
    END IF;
    update "user" set bonus_amount = NEW.amount * 0.05 where user_id = (select user_id from "order" where order_id = NEW.order_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER payment_transaction_trigger
AFTER INSERT ON payment_transaction
FOR EACH ROW
EXECUTE FUNCTION update_payment_status();


-- 2 instead of crypto, we modify password to be crypted with extension

CREATE EXTENSION pgcrypto;

insert into "user" values (DEFAULT, 'Adil2', 'Zhapar', 'zhapar@gmail.com', 87081234567, 'MALE', '2002-08-13', crypt('adil2002', gen_salt('bf')), default, 1);


-- 3
-- trigger to recalculate product rate after new review

CREATE OR REPLACE FUNCTION recalculate_rate()
returns trigger as $$
    declare num_of_reviews INTEGER;
    DECLARE sum_of_reviews FLOAT;
    declare final_result float;
BEGIN
    num_of_reviews := (SELECT COUNT(review_id) from product_review where product_id = NEW.product_id);
    sum_of_reviews := (SELECT SUM(rating) from product_review where product_id = NEW.product_id);
    final_result := round((sum_of_reviews / num_of_reviews)::numeric, 2)::float;
    update product set rating_score = final_result where product_id=NEW.product_id;

    return NEW;
end;
$$ language plpgsql;

create trigger rate_calculator_trigger
AFTER INSERT OR UPDATE ON product_review
FOR EACH ROW
EXECUTE FUNCTION recalculate_rate();


-- 4
-- Trigger to prevent an order from being canceled or refunded if it has already been delivered
CREATE OR REPLACE FUNCTION check_order_status()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status = 'DELIVERED' THEN
        RAISE EXCEPTION 'Cannot cancel or refund an order that has already been delivered';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_order_status_trigger
BEFORE UPDATE ON "order"
FOR EACH ROW
WHEN (NEW.status = 'CANCELED')
EXECUTE FUNCTION check_order_status();

insert into "user" values (DEFAULT, 'Test_first_name', 'Test_last_name', 'test@gmail.com', '+77021867777', 'MALE', '2001-01-01', crypt('test', gen_salt('bf')), default, 1);
insert into user_address values (DEFAULT, 2, 1);
insert into "order"(user_id, order_type, address_id) values (1, 'INCOME', 1);
insert into order_product values (11, 3, 1, 4);
insert into order_product values (12, 3, 1, 4);
insert into order_product values (11, 2, 1, 4);
insert into payment_transaction values (default, 11, 'CREDIT_CARD', 'KASPI', 1200, NULL);


insert into "order"(user_id, order_type, address_id) values (1, 'INCOME', 1);
select * from "order";

insert into order_product(order_id, product_id, store_id, quantity) values (13, 3, 1, 4);
select * from "order";

insert into payment_transaction(order_id, payment_method, payment_platform, amount) values (13, 'CREDIT_CARD', 'KASPI', 1200);
select * from payment_transaction;
select * from "order";
update "order" set status = 'DELIVERED' where order_id = 13;
select * from "order";

insert into "order"(user_id, order_type, address_id, refund_reason, income_order_id) values (1, 'REFUND', 1, 'some_reason', 13);
select * from "order";

insert into order_product(order_id, product_id, store_id, quantity) values (16, 3, 1, 2);
select * from "order";
insert into order_product(order_id, product_id, store_id, quantity) values(16, 2, 1, 2);

insert into payment_transaction(order_id, payment_method, payment_platform, amount) values (16, 'CREDIT_CARD', 'KASPI', -1200);
select * from "order";