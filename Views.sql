-- View 1
create view Bike_model_popularity as
SELECT m.model_name, COUNT(DISTINCT rd.rental_id) AS rides_number
FROM Model m
LEFT JOIN Bike b ON m.model_id = b.model_id
LEFT JOIN Rental_detail rd ON b.bike_id = rd.bike_id
GROUP BY m.model_name;

-- View 2 (editable)
create view memberships_info as
select m.membership_type_id, m.membership_type_name, m.membership_price, m.membership_description
from membership m
with check option;
