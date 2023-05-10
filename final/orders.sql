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
        values(new.order_id, payment_info.payment_method, payment_info.payment_platform, new.total_price);
    end if;
    return new;
end;
$$ language plpgsql;

create or replace function update_order()
returns trigger
as $$
    declare
        r record;
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
            update "order" set total_price = total_price + (product_price * new.quantity);
        else
            raise exception 'Not enough quantity available';
        end if;
    else
        select o.income_order_id into _income_order_id from "order" o where o.order_id = new.order_id;
        if new.product_id not in (select product_id from order_product where order_id = _income_order_id) then
            raise exception 'Product not in income order';
        else
            update "order" set total_price = total_price - (product_price * new.quantity);
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
create trigger order_update_trigger after update on "order" for each row execute procedure update_order();
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