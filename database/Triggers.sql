-- 7. Trigger — Log every new ticket insertion
CREATE TABLE Ticket_Log (
  log_id   INT AUTO_INCREMENT PRIMARY KEY,
  ticket_id INT,
  package_id INT,
  visit_date DATETIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
DELIMITER //
CREATE TRIGGER after_ticket_insert
AFTER INSERT ON Ticket
FOR EACH ROW
BEGIN
  INSERT INTO Ticket_Log(ticket_id, package_id, visit_date)
  VALUES (NEW.ticket_id, NEW.package_id, NEW.visit_date);
END;
//
DELIMITER ;