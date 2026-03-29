-- Insert sample products
INSERT INTO products (name, description, price, stock, sku, created_at, updated_at) VALUES 
('iPhone 15 Pro', 'Latest Apple flagship with A17 Pro chip', 99999, 10, 'IPHONE15PRO', NOW(), NOW()),
('Samsung Galaxy S24', 'Premium Android phone with AI features', 89999, 8, 'GALAXY_S24', NOW(), NOW()),
('MacBook Pro 14', 'Powerful laptop with M3 Pro chip', 199999, 5, 'MACBOOK_PRO_14', NOW(), NOW()),
('iPad Air', 'Versatile tablet for work and creativity', 54999, 12, 'IPAD_AIR', NOW(), NOW()),
('Sony WH-1000XM5', 'Industry-leading noise cancelling headphones', 29999, 15, 'SONY_HEADPHONES', NOW(), NOW()),
('DJI Air 3S', 'Professional drone with advanced features', 79999, 6, 'DJI_AIR3S', NOW(), NOW());

-- Note: Test user will be created by DataInitializer after tables are created with proper password encoding
