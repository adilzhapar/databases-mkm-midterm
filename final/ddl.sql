create table city(
    city_id serial primary key,
    name varchar(50) not null
);

create table "user"(
    user_id serial primary key,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    email varchar(50) not null unique,
    phone varchar(50) not null unique,
    gender varchar(50) not null,
    birth_date date not null,
    password varchar not null,
    bonus_amount int not null default 0,
    city_id int references city(city_id),
    constraint check_gender check ( gender in ('MALE', 'FEMALE') )
);

-- create table user_address(
--     user_address_id serial primary key,
--     user_id int references "user"(user_id),
--     street varchar not null,
--     house_number int not null,
--     floor int not null
-- );
-- user_id has partial dependency, which is not in 2nd form

-- Solution:
create table address(
    address_id serial primary key,
    street varchar not null,
    house_number int not null,
    floor int not null
);

create table user_address(
    user_address_id serial primary key,
    user_id int references "user"(user_id),
    address_id int references address(address_id)
);




create table store(
    store_id serial primary key,
    address varchar not null,
    open_from time not null,
    open_to time not null,
    city_id int references city(city_id)
);

create table category(
    category_id serial primary key,
    title varchar not null,
    parent_id int references category(category_id)
);

create table product(
    product_id serial primary key,
    title varchar not null,
    description varchar not null,
    full_description varchar,
    price int not null,
    rating_score float,
    category_id int references category(category_id)
);

create table store_inventory(
    store_id int references store(store_id),
    product_id int references product(product_id),
    quantity int not null default 0,
    primary key (store_id, product_id)
);

create table product_review(
    review_id serial primary key,
    review text not null,
    rating float not null,
    user_id int references "user"(user_id),
    product_id int references product(product_id)
);

create table "order"(
    order_id serial primary key,
    user_id int references "user"(user_id),
    order_date date not null,
    delivery_date date,
    total_price int not null,
    status varchar not null,
    order_type varchar(50) not null,
    refund_reason text,
    address_id int references user_address(user_address_id),
    constraint check_order_type check (order_type in ('INCOME', 'REFUND')),
    constraint check_status check (status in ('PENDING', 'CANCELED', 'IN_PROCESS', 'DELIVERED', 'REFUNDED'))
);

create table order_product(
    order_id int references "order"(order_id),
    product_id int references product(product_id),
    store_id int references store(store_id),
    quantity int not null,
    primary key (order_id, product_id)
);

create table payment_transaction(
    transaction_id serial primary key,
    order_id int references "order"(order_id),
    payment_method varchar(50) not null,
    payment_platform varchar(50),
    amount int not null,
    constraint check_payment_method check (payment_method in ('CASH', 'CREDIT_CARD'))
);