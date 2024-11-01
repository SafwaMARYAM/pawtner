<?php
include 'db_conn.php';

$sql = "
    SELECT
        pets.pet_id,
        pets.pet_name, 
        pets.image, 
        pets.description, 
        pets.age, 
        pets.breed, 
        pets.size, 
        pets.gender, 
        shelters.name AS shelter_name, 
        shelters.place AS shelter_place, 
        shelters.phone AS shelter_phone, 
        volunteers.volunteer_id, 
        volunteers.name AS volunteer_name
    FROM 
        pets
    JOIN 
        shelters ON pets.shelter_id = shelters.shelter_id
    JOIN 
        volunteers ON pets.volunteer_id = volunteers.volunteer_id
    WHERE 
        pets.adoption_status = 'no';
";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    // Output data for each row
    $pets_data = [];
    while($row = $result->fetch_assoc()) {
        $pets_data[] = $row;
    }
    echo json_encode($pets_data);
} else {
    echo json_encode([]);
}

$conn->close();
?>
