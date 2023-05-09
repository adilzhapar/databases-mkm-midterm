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







