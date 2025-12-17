USE national_park;
DELIMITER $$

CREATE PROCEDURE RegisterVisitorAndTicket(
    IN p_name VARCHAR(100),
    IN p_contact VARCHAR(20),
    IN p_visit_date DATE,
    IN p_payment_mode VARCHAR(50),
    IN p_ticket_type VARCHAR(50),
    IN p_visitor_count INT,
    IN p_package_id INT
)
BEGIN
    DECLARE new_v_id INT;
    DECLARE new_t_id INT;

    SELECT COALESCE(MAX(visitor_id), 0) + 1 INTO new_v_id 
    FROM Visitor;
    SELECT COALESCE(MAX(ticket_id), 0) + 1 INTO new_t_id 
    FROM Ticket;

    INSERT INTO Visitor (visitor_id, visitor_name, contact_no)
    VALUES (new_v_id, p_name, p_contact);

    INSERT INTO Ticket (ticket_id, visitor_id, visit_date, payment_mode, ticket_type, visitor_count, package_id)
    VALUES (new_t_id, new_v_id, p_visit_date, p_payment_mode, p_ticket_type, p_visitor_count, p_package_id);
END $$
DELIMITER ;
CALL RegisterVisitorAndTicket('Aditi Hydari', '9876543510', '2025-12-09', 'Credit Card', 'Adult', 2, 112);

