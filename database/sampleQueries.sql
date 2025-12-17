-- 1.Which Zone Has the Highest Animal Density?
SELECT Z.zone_name,
       COUNT(A.animal_id)       AS animals_in_zone,
       COUNT(T.ticket_id)       AS visits
FROM Zone Z
LEFT JOIN Habitat H ON Z.zone_id = H.zone_id
LEFT JOIN Enclosure E ON H.habitat_id = E.habitat_id
LEFT JOIN Animal A ON A.enclosure_id = E.enclosure_id
LEFT JOIN Package_zones PZ ON Z.zone_id = PZ.zone_id
LEFT JOIN Tour_Package TP ON PZ.package_id = TP.package_id
LEFT JOIN Ticket T ON TP.package_id = T.package_id
GROUP BY Z.zone_id
ORDER BY animals_in_zone DESC, visits DESC;

-- 2. List all animals with their enclosure, habitat, and zone
SELECT 
    a.animal_id,
    a.animal_name,
    e.enclosure_name,
    h.habitat_name,
    z.zone_name
FROM Animal a
JOIN Enclosure e ON a.enclosure_id = e.enclosure_id
JOIN Habitat h ON e.habitat_id = h.habitat_id
JOIN Zone z ON h.zone_id = z.zone_id;

-- 3. Show supervisors and how many zones they manage
SELECT 
    s.staff_name AS supervisor,
    COUNT(z.zone_id) AS zones_managed
FROM Supervisor su
JOIN Staff s ON su.staff_id = s.staff_id
LEFT JOIN Zone z ON su.staff_id = z.sup_id
GROUP BY su.staff_id, s.staff_name;

-- 4.Get guides whose rating is above the average guide rating
SELECT 
    st.staff_name,
    g.guide_rating
FROM Guide g
JOIN Staff st ON g.staff_id = st.staff_id
WHERE g.guide_rating > (
    SELECT AVG(guide_rating) FROM Guide
);

-- 5.Revenue generated through tour packages

SELECT tp.package_name AS package_name,
       SUM(t.visitor_count * tp.price) AS total_revenue
FROM Ticket t
JOIN Tour_Package tp ON tp.package_id = t.package_id
GROUP BY tp.package_id;
