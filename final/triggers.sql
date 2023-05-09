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
            UPDATE "order" SET status = 'CANCELED' WHERE order_id = NEW.order_id;
        END IF;
    ELSE
        update payment_transaction set status = 'SUCCESS' where transaction_id = NEW.transaction_id;
        UPDATE "order" SET status = 'IN_PROCESS' WHERE order_id = NEW.order_id;
    END IF;

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

