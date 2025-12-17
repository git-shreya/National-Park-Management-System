CREATE DATABASE national_park;
USE national_park;
-- 1) Staff (base table for all staff-role subtables)
CREATE TABLE IF NOT EXISTS Staff (
    staff_id INT PRIMARY KEY,
    staff_name VARCHAR(100) NOT NULL,
    salary DECIMAL(12,2) DEFAULT 0.00,
    staff_role VARCHAR(50) NOT NULL,
    sup_id INT DEFAULT NULL, -- optional manager/supervisor (references Staff)
    CONSTRAINT fk_staff_sup
      FOREIGN KEY (sup_id) REFERENCES Staff(staff_id)
      ON DELETE SET NULL ON UPDATE CASCADE
) ;
-- 1) Staff (base table)
INSERT INTO Staff (staff_id, staff_name, salary, staff_role, sup_id) VALUES
(1, 'Alice', 50000, 'Supervisor', NULL),
(2, 'Frank', 28000, 'Supervisor', NULL),
(3, 'Bob', 30000, 'Guide', 1),
(4, 'David', 20000, 'Guide', 1),
(5, 'Charlie', 25000, 'Caretaker', 2),
(6, 'Eve', 22000, 'Caretaker', 2),
(7, 'Grace', 24000, 'Caretaker', 2),
(8, 'Aysel', 20000, 'Guide', 1);


-- 2) Supervisor (subtype of Staff)
CREATE TABLE IF NOT EXISTS Supervisor (
    staff_id INT PRIMARY KEY, -- same id as in Staff
    years_of_exp INT DEFAULT 0,
    grade_level VARCHAR(50),
    area_of_supervision VARCHAR(150),
    CONSTRAINT fk_supervisor_staff
      FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
      ON DELETE CASCADE ON UPDATE CASCADE
) ;
-- 2) Supervisor
INSERT INTO Supervisor (staff_id, years_of_exp, grade_level, area_of_supervision) VALUES
(1, 10, 'A', 'Tourist Facility Zone'),
(2, 8, 'B', 'Safari Zone');

-- 3) Guide (subtype of Staff)
CREATE TABLE IF NOT EXISTS Guide (
    staff_id INT PRIMARY KEY,
    guide_rating DECIMAL(3,2) DEFAULT NULL, -- e.g. 4.50
    CONSTRAINT fk_guide_staff
      FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
      ON DELETE CASCADE ON UPDATE CASCADE
);
-- 3) Guide
INSERT INTO Guide (staff_id, guide_rating) VALUES
(3, 4.5),
(4, 4.0),
(8, 4.2);

-- 4) Caretaker (subtype of Staff)
CREATE TABLE IF NOT EXISTS Caretaker (
    staff_id INT PRIMARY KEY,
    assigned_area VARCHAR(150),
    shift_timing VARCHAR(100),
    CONSTRAINT fk_caretaker_staff
      FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
      ON DELETE CASCADE ON UPDATE CASCADE
);

-- 4) Caretaker
INSERT INTO Caretaker (staff_id, assigned_area, shift_timing) VALUES
(3, 'Safari Zone', 'Morning'),
(5, 'Enclosure Zone', 'Evening'),
(7, 'Safari Zone', 'Afternoon');

-- 5) Zone (references Supervisor.staff_id)
CREATE TABLE IF NOT EXISTS Zone (
    zone_id INT PRIMARY KEY,
    zone_name VARCHAR(100) NOT NULL,
    sup_id INT DEFAULT NULL, -- supervisor responsible for zone
    CONSTRAINT fk_zone_supervisor
      FOREIGN KEY (sup_id) REFERENCES Supervisor(staff_id)
      ON DELETE SET NULL ON UPDATE CASCADE
);

-- 5) Zones (administrative)
INSERT INTO Zone (zone_id, zone_name, sup_id) VALUES
(101,'Safari Zone', 1),
(102,'Tourist Facility Zone', 1),
(103,'Enclosure Zone', 1),
(104,'Bird Zone', 2),
(105,'Reptile Zone', 2);

-- 6) Tourist Facilities
CREATE TABLE IF NOT EXISTS Tourist_Facilities (
    facility_id INT PRIMARY KEY,
    zone_id INT NOT NULL,
    facility_type VARCHAR(100) NOT NULL,
    operating_hours VARCHAR(100),
    CONSTRAINT fk_facility_zone
      FOREIGN KEY (zone_id) REFERENCES Zone(zone_id)
      ON DELETE CASCADE ON UPDATE CASCADE
      );

-- 6) Tourist Facilities
INSERT INTO Tourist_Facilities (facility_id,zone_id, facility_type, operating_hours) VALUES
(201,102, 'Snack Bar', '09:00-17:00'),
(202,102, 'Gift Shop', '10:00-16:00'),
(203,102, 'Cafe', '08:00-18:00'),
(204,102, 'Souvenir Shop', '09:00-17:00'),
(205,102, 'Photo Booth', '10:00-16:00');

-- 7) Tourist facilities_staff assignment
CREATE TABLE IF NOT EXISTS Tourist_Staff (
    staff_id INT NOT NULL,
    facility_id INT NOT NULL,

    PRIMARY KEY (staff_id, facility_id),

    CONSTRAINT fk_touriststaff_staff
      FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
      ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_touriststaff_facility
      FOREIGN KEY (facility_id) REFERENCES Tourist_Facilities(facility_id)
      ON DELETE CASCADE ON UPDATE CASCADE
);
-- 7) Tourist Staff (M:N)
INSERT INTO Tourist_Staff (staff_id, facility_id) VALUES
(2, 201),
(4, 202),
(6, 203),
(2, 204),
(4, 205);

-- 8) staff_contact (multiple contacts per staff allowed)
CREATE TABLE IF NOT EXISTS staff_contact (
    contact_id INT PRIMARY KEY,
    staff_id INT NOT NULL,
    contact VARCHAR(50) NOT NULL,
    contact_type VARCHAR(30) DEFAULT NULL,
    CONSTRAINT fk_staffcontact_staff
      FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
      ON DELETE CASCADE ON UPDATE CASCADE
);

-- 8) Staff Contacts
INSERT INTO staff_contact (contact_id, staff_id, contact, contact_type) VALUES
(1,1, '9876345112', 'Office'),
(2,1, '6283476587', 'Mobile'),
(3,3, '8871236782', 'Mobile'),
(4,4, '6735476523', 'Mobile'),
(5,5, '9876234665', 'Mobile');


-- 9) Habitat (belongs to a Zone)
CREATE TABLE IF NOT EXISTS Habitat (
    habitat_id INT PRIMARY KEY,
    habitat_name VARCHAR(150) NOT NULL,
    zone_id INT NOT NULL,
    CONSTRAINT fk_habitat_zone
      FOREIGN KEY (zone_id) REFERENCES Zone(zone_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 9) Habitat (linked to zones)
INSERT INTO Habitat (habitat_id, habitat_name, zone_id) VALUES
(111, 'Tropical Forest Habitat', 101),   -- Safari Zone
(112, 'Mangrove Wetland Habitat', 103),  -- Enclosure Zone
(113, 'Grassland Habitat', 101),         -- Safari Zone
(114, 'Riverine Habitat', 104),          -- Bird Zone
(115, 'Bird Sanctuary Habitat', 104);    -- Bird Zone


-- 10) Enclosure (belongs to a Habitat)
CREATE TABLE IF NOT EXISTS Enclosure (
    enclosure_id INT PRIMARY KEY,
    habitat_id INT NOT NULL,
    enclosure_name VARCHAR(150) NOT NULL,
    CONSTRAINT fk_enclosure_habitat
      FOREIGN KEY (habitat_id) REFERENCES Habitat(habitat_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 10) Enclosure
INSERT INTO Enclosure (enclosure_id, habitat_id, enclosure_name) VALUES
(501, 111, 'Lion Enclosure'),
(502, 112, 'Otter Enclosure'),             -- wetland animal
(503, 113, 'Elephant Enclosure'),           -- grassland animal
(504, 114, 'Kingfisher Enclosure'),         -- riverine birds
(505, 115, 'Parrot Aviary');                -- tropical birds


-- 11) Species (independent)
CREATE TABLE IF NOT EXISTS Species (
    species_id INT PRIMARY KEY,
    scientificname VARCHAR(200) NOT NULL,
    cons_status VARCHAR(100),
    common_name VARCHAR(150),
    primary_diet_type VARCHAR(100),
    avg_lifespan INT
);

-- 11) Species
INSERT INTO Species (species_id, scientificname, cons_status, common_name, primary_diet_type, avg_lifespan) VALUES
(1, 'Panthera leo', 'Vulnerable', 'Lion', 'Carnivore', 15),
(2, 'Lutra lutra', 'Near Threatened', 'Otter', 'Carnivore', 12),
(3, 'Elephas maximus', 'Endangered', 'Elephant', 'Herbivore', 60),
(4, 'Alcedo atthis', 'Least Concern', 'Kingfisher', 'Carnivore', 10),
(5, 'Ara macao', 'Least Concern', 'Scarlet Macaw', 'Herbivore', 50);


-- 12) Animal (references Enclosure and Species)

CREATE TABLE IF NOT EXISTS Animal (
    animal_id INT PRIMARY KEY,
    animal_name VARCHAR(120) NOT NULL,
    gender ENUM('M','F','U') DEFAULT 'U',
    health_status VARCHAR(100),
    DOB DATE,
    enclosure_id INT DEFAULT NULL,
    species_id INT DEFAULT NULL,
    
    CONSTRAINT fk_animal_enclosure
      FOREIGN KEY (enclosure_id) REFERENCES Enclosure(enclosure_id)
      ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_animal_species
      FOREIGN KEY (species_id) REFERENCES Species(species_id)
      ON DELETE SET NULL ON UPDATE CASCADE
);

INSERT INTO Animal (animal_id, animal_name, gender, health_status, DOB, enclosure_id, species_id) VALUES
(1, 'Simba', 'M', 'Healthy', '2010-06-01', 501, 1),   -- Lion
(2, 'Ollie', 'F', 'Healthy', '2015-03-12', 502, 2),    -- Otter
(3, 'Ella', 'F', 'Healthy', '2008-05-20', 503, 3),     -- Elephant
(4, 'Kiko', 'M', 'Healthy', '2018-09-10', 504, 4),     -- Kingfisher
(5, 'Coco', 'F', 'Healthy', '2012-11-11', 505, 5);     -- Macaw


-- 13) Visitor (independent)
CREATE TABLE IF NOT EXISTS Visitor (
    visitor_id INT PRIMARY KEY,
    visitor_name VARCHAR(120) NOT NULL,
    contact_no VARCHAR(30)
);

-- 13) Visitor
INSERT INTO Visitor (visitor_id,visitor_name, contact_no) VALUES
(121,'John Doe', '9876543210'),
(122,'Jane Smith', '9123456780'),
(123,'Mike Brown', '9988776655'),
(124,'Emma White', '9112233445'),
(125,'Liam Green', '9001122334');

-- 14) Tour_Package (references Guide and Supervisor)
CREATE TABLE IF NOT EXISTS Tour_Package (
    package_id INT PRIMARY KEY,
    package_name VARCHAR(150) NOT NULL,
    duration INT, -- duration in minutes/hours as you prefer
    guide_id INT DEFAULT NULL, -- expects Guide.staff_id
    price DECIMAL(10,2) DEFAULT 0.00,
    sup_id INT DEFAULT NULL, -- supervising staff (Supervisor)
    CONSTRAINT fk_tourpackage_guide
      FOREIGN KEY (guide_id) REFERENCES Guide(staff_id)
      ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_tourpackage_supervisor
      FOREIGN KEY (sup_id) REFERENCES Supervisor(staff_id)
      ON DELETE SET NULL ON UPDATE CASCADE
);

-- 14) Tour Packages
INSERT INTO Tour_Package (package_id,package_name, duration, guide_id, price, sup_id) VALUES
(111,'Tropical Adventure', 120, 3, 100.00, 1),
(112,'Wetland Trail', 90, 4, 80.00, 1),
(113,'Lion Trek', 150, 8, 120.00, 2),
(114,'Bird Watch', 60, 3, 50.00, 1),
(115,'Reptile Expedition', 90, 8, 90.00, 2);


-- 15) Package_zones (many-to-many: packages <-> zones)
CREATE TABLE IF NOT EXISTS Package_zones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    package_id INT NOT NULL,
    zone_id INT NOT NULL,
    CONSTRAINT uq_package_zone UNIQUE (package_id, zone_id),
    CONSTRAINT fk_packagezones_package
      FOREIGN KEY (package_id) REFERENCES Tour_Package(package_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_packagezones_zone
      FOREIGN KEY (zone_id) REFERENCES Zone(zone_id)
      ON DELETE CASCADE ON UPDATE CASCADE
) ;

-- 15) Package Zones (M:N)
INSERT INTO Package_zones (package_id, zone_id) VALUES
(111, 101),
(112, 102),
(113, 101),
(114, 104),
(115, 105);

-- 16) Enclosure_caretaker (assign caretakers to enclosures)
CREATE TABLE IF NOT EXISTS Enclosure_caretaker (
    id INT AUTO_INCREMENT PRIMARY KEY,
    staff_id INT NOT NULL,
    enclosure_id INT NOT NULL,
    assigned_from DATE DEFAULT NULL,
    assigned_to DATE DEFAULT NULL,
    CONSTRAINT uq_enclosure_caretaker UNIQUE (staff_id, enclosure_id),
    CONSTRAINT fk_enclosurecaretaker_caretaker
      FOREIGN KEY (staff_id) REFERENCES Caretaker(staff_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_enclosurecaretaker_enclosure
      FOREIGN KEY (enclosure_id) REFERENCES Enclosure(enclosure_id)
      ON DELETE CASCADE ON UPDATE CASCADE
);

-- 16) Enclosure Caretakers (M:N)
INSERT INTO Enclosure_caretaker (staff_id, enclosure_id, assigned_from, assigned_to) VALUES
(3, 501, '2025-05-01', '2026-12-31'),
(5, 502, '2025-06-21', '2027-12-31'),
(7, 503, '2025-03-11', '2027-12-31'),
(3, 504, '2025-02-27', '2026-12-31'),
(5, 505, '2025-01-09', '2026-12-31');

-- 17) Ticket (references Visitor and Tour_Package)
CREATE TABLE IF NOT EXISTS Ticket (
    ticket_id INT PRIMARY KEY,
    visitor_id INT NOT NULL,
    visit_date DATE NOT NULL,
    payment_mode VARCHAR(50),
    ticket_type VARCHAR(50),
    visitor_count INT DEFAULT 1,
    package_id INT DEFAULT NULL,
    CONSTRAINT fk_ticket_visitor
      FOREIGN KEY (visitor_id) REFERENCES Visitor(visitor_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ticket_package
      FOREIGN KEY (package_id) REFERENCES Tour_Package(package_id)
      ON DELETE SET NULL ON UPDATE CASCADE
);

-- 17) Tickets
INSERT INTO Ticket (ticket_id,visitor_id, visit_date, payment_mode, ticket_type, visitor_count, package_id) VALUES
(610,121, '2025-12-01', 'Credit Card', 'Adult', 2, 111),
(611,122, '2025-12-05', 'Cash', 'Child', 1, 112),
(612,123, '2025-12-10', 'UPI', 'Adult', 3, 113),
(613,124, '2025-12-12', 'Credit Card', 'Adult', 1, 114),
(614,125, '2025-12-15', 'Cash', 'Adult', 2, 115);
