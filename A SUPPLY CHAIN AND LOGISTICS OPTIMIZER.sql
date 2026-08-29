CREATE DATABASE IF NOT EXISTS supply_chain_optimizer;
USE supply_chain_optimizer;

DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS carriers;
DROP TABLE IF EXISTS warehouses;

CREATE TABLE warehouses (
    warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_code VARCHAR(20) NOT NULL UNIQUE,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    storage_capacity_sqft INT NOT NULL
);

CREATE TABLE carriers (
    carrier_id INT AUTO_INCREMENT PRIMARY KEY,
    carrier_name VARCHAR(100) NOT NULL UNIQUE,
    tier ENUM('Tier 1','Tier 2','Tier 3') NOT NULL,
    contracted_sla_days INT NOT NULL,
    base_rate_per_km DECIMAL(8,2) NOT NULL
);

CREATE TABLE shipments (
    shipment_id VARCHAR(50) PRIMARY KEY,
    origin_warehouse_id INT NOT NULL,
    destination_warehouse_id INT NOT NULL,
    carrier_id INT NOT NULL,
    distance_km DECIMAL(10,2) NOT NULL,
    weight_kg DECIMAL(10,2) NOT NULL,
    shipping_cost DECIMAL(10,2) NOT NULL,
    shipped_date DATE NOT NULL,
    estimated_delivery_date DATE NOT NULL,
    actual_delivery_date DATE NULL,
    delivery_status ENUM('On Time', 'Delayed', 'In Transit', 'Cancelled') NOT NULL,
    CONSTRAINT fk_ship_origin FOREIGN KEY (origin_warehouse_id)
        REFERENCES warehouses(warehouse_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ship_dest FOREIGN KEY (destination_warehouse_id)
        REFERENCES warehouses(warehouse_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ship_carrier FOREIGN KEY (carrier_id)
        REFERENCES carriers(carrier_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 1. Insert Warehouses
INSERT INTO warehouses (warehouse_id, warehouse_code, city, country, storage_capacity_sqft) VALUES
(1, 'WH-NBO-01', 'Nairobi', 'Kenya', 85000),
(2, 'WH-MSA-02', 'Mombasa', 'Kenya', 120000),
(3, 'WH-KSM-03', 'Kisumu', 'Kenya', 60000),
(4, 'WH-ELD-04', 'Eldoret', 'Kenya', 65000),
(5, 'WH-KMA-05', 'Kampala', 'Uganda', 95000),
(6, 'WH-DAR-06', 'Dar es Salaam', 'Tanzania', 110000),
(7, 'WH-KGL-07', 'Kigali', 'Rwanda', 70000),
(8, 'WH-JNB-08', 'Johannesburg', 'South Africa', 150000),
(9, 'WH-LOS-09', 'Lagos', 'Nigeria', 140000),
(10, 'WH-CAI-10', 'Cairo', 'Egypt', 130000);

-- 2. Insert Carriers
INSERT INTO carriers (carrier_id, carrier_name, tier, contracted_sla_days, base_rate_per_km) VALUES
(1, 'SwiftLogistics Ltd', 'Tier 1', 3, 45.00),
(2, 'EastAfrican Express', 'Tier 2', 5, 35.00),
(3, 'Rift Valley Freight', 'Tier 1', 3, 40.00),
(4, 'Savannah Cargo Co', 'Tier 3', 7, 25.00),
(5, 'Kilimanjaro Hauliers', 'Tier 2', 6, 30.00),
(6, 'PanAfrican Global', 'Tier 1', 4, 50.00),
(7, 'TransSahel Transport', 'Tier 3', 8, 22.00);

-- 3. Insert Shipments
INSERT INTO shipments (shipment_id, origin_warehouse_id, destination_warehouse_id, carrier_id, distance_km, weight_kg, shipping_cost, shipped_date, estimated_delivery_date, actual_delivery_date, delivery_status) VALUES
('SHP-00001', 1, 2, 1, 485.50, 250.00, 23000.00, '2026-01-10', '2026-01-13', '2026-01-13', 'On Time'),
('SHP-00002', 2, 3, 4, 920.00, 1100.00, 31000.00, '2026-01-12', '2026-01-19', '2026-01-22', 'Delayed'),
('SHP-00003', 1, 5, 2, 650.25, 450.50, 22750.00, '2026-01-15', '2026-01-20', '2026-01-20', 'On Time'),
('SHP-00004', 3, 1, 3, 350.00, 120.00, 15500.00, '2026-01-18', '2026-01-21', '2026-01-21', 'On Time'),
('SHP-00005', 4, 2, 4, 850.00, 1800.00, 38250.00, '2026-01-20', '2026-01-27', '2026-01-30', 'Delayed'),
('SHP-00006', 5, 1, 1, 650.25, 300.00, 20750.00, '2026-02-01', '2026-02-04', '2026-02-04', 'On Time'),
('SHP-00007', 2, 4, 2, 1100.00, 950.00, 37250.00, '2026-02-05', '2026-02-10', '2026-02-12', 'Delayed'),
('SHP-00008', 1, 6, 5, 980.00, 850.00, 34200.00, '2026-02-08', '2026-02-14', '2026-02-14', 'On Time'),
('SHP-00009', 3, 5, 4, 450.00, 780.00, 20100.00, '2026-02-10', '2026-02-17', '2026-02-17', 'On Time'),
('SHP-00010', 4, 1, 1, 320.00, 150.00, 15100.00, '2026-02-14', '2026-02-17', '2026-02-19', 'Delayed'),
('SHP-00011', 6, 2, 3, 1150.00, 1400.00, 42100.00, '2026-02-18', '2026-02-21', '2026-02-21', 'On Time'),
('SHP-00012', 2, 1, 3, 485.50, 340.00, 21200.00, '2026-02-22', '2026-02-25', '2026-02-25', 'On Time'),
('SHP-00013', 5, 3, 4, 780.00, 1250.00, 30100.00, '2026-03-01', '2026-03-08', '2026-03-11', 'Delayed'),
('SHP-00014', 3, 2, 1, 890.00, 620.00, 29500.00, '2026-03-04', '2026-03-07', '2026-03-07', 'On Time'),
('SHP-00015', 4, 6, 5, 1020.00, 750.00, 35600.00, '2026-03-06', '2026-03-12', '2026-03-15', 'Delayed'),
('SHP-00016', 1, 7, 6, 1250.00, 520.00, 45200.00, '2026-03-10', '2026-03-14', '2026-03-14', 'On Time'),
('SHP-00017', 7, 5, 2, 420.00, 310.00, 18400.00, '2026-03-12', '2026-03-17', '2026-03-17', 'On Time'),
('SHP-00018', 8, 1, 6, 3950.00, 2400.00, 115000.00, '2026-03-14', '2026-03-22', '2026-03-25', 'Delayed'),
('SHP-00019', 9, 8, 7, 4800.00, 3100.00, 132000.00, '2026-03-15', '2026-03-25', NULL, 'In Transit'),
('SHP-00020', 10, 9, 6, 5200.00, 1850.00, 128000.00, '2026-03-18', '2026-03-27', NULL, 'In Transit'),
('SHP-00021', 1, 8, 6, 4100.00, 920.00, 98500.00, '2026-03-20', '2026-03-28', '2026-03-28', 'On Time'),
('SHP-00022', 2, 10, 7, 5600.00, 1450.00, 112000.00, '2026-03-22', '2026-04-02', NULL, 'In Transit'),
('SHP-00023', 5, 7, 2, 400.00, 600.00, 19500.00, '2026-03-25', '2026-03-30', '2026-03-30', 'On Time'),
('SHP-00024', 3, 4, 3, 430.00, 280.00, 17200.00, '2026-03-26', '2026-03-29', '2026-03-31', 'Delayed'),
('SHP-00025', 6, 1, 1, 980.00, 710.00, 36400.00, '2026-03-28', '2026-04-01', '2026-04-01', 'On Time');

-- CREATING ANALYTICAL VIEW

USE supply_chain_optimizer;
CREATE OR REPLACE VIEW vw_shipment_details AS
SELECT 
    s.shipment_id,
    origin.warehouse_code AS origin_code,
    origin.city AS origin_city,
    dest.warehouse_code AS destination_code,
    dest.city AS destination_city,
    c.carrier_name,
    s.shipping_cost,
    s.delivery_status
FROM shipments s
JOIN warehouses origin ON s.origin_warehouse_id = origin.warehouse_id
JOIN warehouses dest ON s.destination_warehouse_id = dest.warehouse_id
JOIN carriers c ON s.carrier_id = c.carrier_id;
SELECT * FROM vw_shipment_details LIMIT 5;

-- Carrier Performance and Reliability Analysis
USE supply_chain_optimizer;

CREATE OR REPLACE VIEW vw_carrier_performance AS
SELECT 
    c.carrier_id,
    c.carrier_name,
    c.tier,
    COUNT(s.shipment_id) AS total_shipments,
    ROUND(AVG(s.shipping_cost), 2) AS avg_shipping_cost,
    SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) AS on_time_deliveries,
    SUM(CASE WHEN s.delivery_status = 'Delayed' THEN 1 ELSE 0 END) AS delayed_deliveries,
    ROUND(
        (SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0) / COUNT(s.shipment_id), 
        2
    ) AS on_time_percentage
FROM carriers c
LEFT JOIN shipments s ON c.carrier_id = s.carrier_id
GROUP BY c.carrier_id, c.carrier_name, c.tier;


SELECT * FROM vw_carrier_performance;

-- 3. Warehouse Activity & Throughput View
CREATE OR REPLACE VIEW vw_warehouse_activity AS
SELECT 
    w.warehouse_id,
    w.warehouse_code,
    w.city,
    w.country,
    w.storage_capacity_sqft,
    COUNT(DISTINCT outbound.shipment_id) AS total_outbound_shipments,
    COUNT(DISTINCT inbound.shipment_id) AS total_inbound_shipments,
    COALESCE(SUM(outbound.weight_kg), 0) AS total_outbound_weight_kg,
    COALESCE(SUM(outbound.shipping_cost), 0) AS total_outbound_revenue
FROM warehouses w
LEFT JOIN shipments outbound ON w.warehouse_id = outbound.origin_warehouse_id
LEFT JOIN shipments inbound ON w.warehouse_id = inbound.destination_warehouse_id
GROUP BY w.warehouse_id, w.warehouse_code, w.city, w.country, w.storage_capacity_sqft;

-- Instantly view the results
SELECT * FROM vw_warehouse_activity;

-- 4. Route Cost and Distance Efficiency View
CREATE OR REPLACE VIEW vw_route_efficiency AS
SELECT 
    s.shipment_id,
    origin.city AS origin_city,
    dest.city AS destination_city,
    s.distance_km,
    s.weight_kg,
    s.shipping_cost,
    -- Calculate cost per kilometer dynamically
    ROUND(s.shipping_cost / NULLIF(s.distance_km, 0), 2) AS cost_per_km,
    -- Calculate cost per kilogram transported
    ROUND(s.shipping_cost / NULLIF(s.weight_kg, 0), 2) AS cost_per_kg,
    s.delivery_status
FROM shipments s
JOIN warehouses origin ON s.origin_warehouse_id = origin.warehouse_id
JOIN warehouses dest ON s.destination_warehouse_id = dest.warehouse_id;

-- Instantly view the results
SELECT * FROM vw_route_efficiency LIMIT 10;

-- 5. Executive Monthly Summary View
CREATE OR REPLACE VIEW vw_monthly_summary AS
SELECT 
    DATE_FORMAT(s.shipped_date, '%Y-%m') AS shipping_month,
    COUNT(s.shipment_id) AS total_shipments,
    SUM(s.shipping_cost) AS total_monthly_spend,
    ROUND(AVG(s.distance_km), 2) AS avg_distance_km,
    ROUND(AVG(s.weight_kg), 2) AS avg_weight_kg,
    SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) AS on_time_count,
    SUM(CASE WHEN s.delivery_status = 'Delayed' THEN 1 ELSE 0 END) AS delayed_count
FROM shipments s
GROUP BY DATE_FORMAT(s.shipped_date, '%Y-%m')
ORDER BY shipping_month DESC;

-- 1. Identify the Top 5 Most Expensive Shipping Routes per Kilometer
SELECT 
    shipment_id,
    origin_city,
    destination_city,
    distance_km,
    shipping_cost,
    cost_per_km
FROM vw_route_efficiency
ORDER BY cost_per_km DESC
LIMIT 5;

-- 2. Rank Carriers by On-Time Reliability and Total Revenue Generated
SELECT 
    c.carrier_name,
    c.tier,
    cp.total_shipments,
    cp.on_time_percentage,
    SUM(s.shipping_cost) AS total_revenue_generated
FROM vw_carrier_performance cp
JOIN carriers c ON cp.carrier_id = c.carrier_id
JOIN shipments s ON c.carrier_id = s.carrier_id
GROUP BY c.carrier_name, c.tier, cp.total_shipments, cp.on_time_percentage
ORDER BY cp.on_time_percentage DESC, total_revenue_generated DESC;

-- 1. Top Busiest Warehouses by Total Activity (Inbound + Outbound)
SELECT 
    warehouse_code,
    city,
    country,
    storage_capacity_sqft,
    total_outbound_shipments,
    total_inbound_shipments,
    (total_outbound_shipments + total_inbound_shipments) AS total_network_touchpoints,
    total_outbound_revenue
FROM vw_warehouse_activity
ORDER BY total_network_touchpoints DESC;

-- 2. Monthly Financial Spend and Delivery Health Trends
SELECT 
    shipping_month,
    total_shipments,
    total_monthly_spend,
    on_time_count,
    delayed_count,
    ROUND((on_time_count * 100.0) / total_shipments, 2) AS monthly_on_time_rate
FROM vw_monthly_summary
ORDER BY shipping_month ASC;