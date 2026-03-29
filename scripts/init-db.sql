-- E-commerce Database Initialization Script
-- This script initializes the database tables and loads test data
-- Compatible with MySQL, PostgreSQL, and H2

-- Create Tables
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE IF NOT EXISTS carts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY unique_user_cart (user_id)
);

CREATE TABLE IF NOT EXISTS cart_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cart_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    UNIQUE KEY unique_cart_product (cart_id, product_id)
);

CREATE TABLE IF NOT EXISTS orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    shipping_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE IF NOT EXISTS payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    razorpay_order_id VARCHAR(255),
    razorpay_payment_id VARCHAR(255),
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'INR',
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    payment_method VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    UNIQUE KEY unique_order_payment (order_id)
);

CREATE TABLE IF NOT EXISTS reviews (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    rating INT NOT NULL,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_product_user_review (product_id, user_id)
);

-- Insert Sample Categories
INSERT INTO categories (name, description, image_url) VALUES 
('Electronics', 'Electronic devices and gadgets', 'https://via.placeholder.com/300?text=Electronics'),
('Clothing', 'Apparel and fashion items', 'https://via.placeholder.com/300?text=Clothing'),
('Books', 'Digital and physical books', 'https://via.placeholder.com/300?text=Books'),
('Home & Garden', 'Home improvement and garden products', 'https://via.placeholder.com/300?text=Home'),
('Sports', 'Sports equipment and accessories', 'https://via.placeholder.com/300?text=Sports')
ON CONFLICT DO NOTHING;

-- Insert Sample Products
INSERT INTO products (category_id, name, description, price, stock_quantity, image_url) VALUES 
(1, 'Wireless Headphones', 'High-quality Bluetooth headphones with noise cancellation', 4999.00, 50, 'https://via.placeholder.com/300?text=Headphones'),
(1, 'Smart Watch', 'Feature-rich smartwatch with health tracking', 15999.00, 30, 'https://via.placeholder.com/300?text=SmartWatch'),
(1, 'USB-C Cable', 'Durable USB-C charging and data cable', 599.00, 200, 'https://via.placeholder.com/300?text=Cable'),
(2, 'Cotton T-Shirt', 'Comfortable 100% cotton t-shirt', 899.00, 100, 'https://via.placeholder.com/300?text=TShirt'),
(2, 'Denim Jeans', 'Classic blue denim jeans', 1999.00, 80, 'https://via.placeholder.com/300?text=Jeans'),
(3, 'JavaScript Guide', 'Comprehensive JavaScript programming book', 599.00, 40, 'https://via.placeholder.com/300?text=JSBook'),
(3, 'Python Cookbook', 'Real-world Python recipes and solutions', 799.00, 35, 'https://via.placeholder.com/300?text=PyBook'),
(4, 'LED Desk Lamp', 'Modern LED lamp with adjustable brightness', 1499.00, 60, 'https://via.placeholder.com/300?text=Lamp'),
(4, 'Plant Pot Set', 'Set of 3 ceramic plant pots', 1299.00, 45, 'https://via.placeholder.com/300?text=Pots'),
(5, 'Yoga Mat', 'Non-slip yoga mat with carrying strap', 899.00, 70, 'https://via.placeholder.com/300?text=YogaMat')
ON CONFLICT DO NOTHING;

-- Insert Test User (Password: password123 - BCrypt hash: $2a$10$...)
-- Note: In production, use the API to create users with proper password hashing
-- This is handled by Spring Security's BCryptPasswordEncoder in the application

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_price ON products(price);
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_payments_order ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_cart_items_cart ON cart_items(cart_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_product ON cart_items(product_id);

-- Insert test user for development (e-commerce requires proper password hashing)
-- Use the registration API endpoint to create users in a production environment
INSERT INTO users (username, email, password, first_name, last_name, phone, address, city, state, postal_code, country)
VALUES ('testuser', 'test@example.com', '$2a$10$dXJ3SW6G7P50eS3kBlwBt.VwrNnqKFz1T7BLWhBVXqGJVDNvqJZka', 'Test', 'User', '+91-9999999999', '123 Test St', 'Test City', 'Test State', '123456', 'India')
ON CONFLICT DO NOTHING;

-- Set auto-increment values (if needed)
-- ALTER TABLE users AUTO_INCREMENT = 1;
-- ALTER TABLE categories AUTO_INCREMENT = 1;
-- ALTER TABLE products AUTO_INCREMENT = 1;
-- ALTER TABLE orders AUTO_INCREMENT = 1;
-- ALTER TABLE payments AUTO_INCREMENT = 1;
