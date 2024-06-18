-- Create tables
CREATE TABLE app_user (
    id VARCHAR PRIMARY KEY,
    username VARCHAR,
    email VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR,
    user_type VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE app_device (
    id VARCHAR PRIMARY KEY,
    name VARCHAR,
    platform VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE app_quota (
    id VARCHAR PRIMARY KEY,
    amount INTEGER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE app_quota_product (
    id VARCHAR PRIMARY KEY,
    name VARCHAR,
    quota_amount INTEGER,
    description VARCHAR,
    price FLOAT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE app_subscription (
    id VARCHAR PRIMARY KEY,
    name VARCHAR,
    description VARCHAR,
    quota_limit INTEGER,
    price FLOAT,
    level INTEGER,
    duration INTEGER,  -- Duration in days
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE app_user_session (
    id VARCHAR PRIMARY KEY,
    device_id VARCHAR,
    status VARCHAR,
    user_id VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES app_user (id),
    FOREIGN KEY (device_id) REFERENCES app_device (id)
);

CREATE TABLE app_image (
    id VARCHAR PRIMARY KEY,
    url VARCHAR,
    by_service VARCHAR,
    created_session_id VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (created_session_id) REFERENCES app_user_session (id)
);

CREATE TABLE app_quota_buy (
    id VARCHAR PRIMARY KEY,
    user_id VARCHAR,
    apple_receipt_data_jwt VARCHAR,
    quota_product_id VARCHAR,
    quota_id VARCHAR,
    buy_price FLOAT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES app_user (id),
    FOREIGN KEY (quota_product_id) REFERENCES app_quota_product (id),
    FOREIGN KEY (quota_id) REFERENCES app_quota (id)
);

CREATE TABLE app_subscription_transaction (
    id VARCHAR PRIMARY KEY,
    user_id VARCHAR,
    subscription_id VARCHAR,
    quota_id VARCHAR,
    apple_receipt_data_jwt VARCHAR,
    expired_at TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    status VARCHAR,
    FOREIGN KEY (user_id) REFERENCES app_user (id),
    FOREIGN KEY (subscription_id) REFERENCES app_subscription (id),
    FOREIGN KEY (quota_id) REFERENCES app_quota (id)
);

CREATE TABLE app_device_quota (
    id VARCHAR PRIMARY KEY,
    device_id VARCHAR,
    quota_id VARCHAR,
    expired_at TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (device_id) REFERENCES app_device (id),
    FOREIGN KEY (quota_id) REFERENCES app_quota (id)
);

-- Insert records into app_quota_product
INSERT INTO app_quota_product (id, name, quota_amount, description, price, created_at, updated_at)
VALUES 
('com.PhatCH.AniPhoto.Credit', 'Credit', 50, '50 quota for $0.99', 0.99, '2024-05-23 23:51:09.464', '2024-05-23 23:51:09.464');

-- Insert records into app_subscription
INSERT INTO app_subscription (id, name, description, quota_limit, price, level, duration, created_at, updated_at)
VALUES
('com.PhatCH.AniPhoto.Pro.Month', 'Pro', '50 AI generations each month', 50, 0.99, 2, 30, '2024-05-23 15:58:36.687', '2024-05-23 15:58:36.687'),
('com.PhatCH.AniPhoto.Pro.Year', 'Pro', '50 AI generations each month', 50, 9.99, 2, 365, '2024-05-23 15:58:36.687', '2024-05-23 15:58:36.687'),
('com.PhatCH.AniPhoto.ProPlus.Month', 'Pro+', 'Unlimited AI generations', 1000000000, 11.99, 1, 30, '2024-05-23 15:58:36.687', '2024-05-23 15:58:36.687'),
('com.PhatCH.AniPhoto.ProPlus.Year', 'Pro+', 'Unlimited AI generations', 1000000000, 119.99, 1, 365, '2024-05-23 15:58:36.687', '2024-05-23 15:58:36.687');
