let pets = {
    data: []
};

// Function to fetch pet data from the server
async function fetchPets() {
    try {
        const response = await fetch('fetch_pets.php');
        if (!response.ok) {
            throw new Error('Network response was not ok ' + response.statusText);
        }
        const petData = await response.json();
        console.log(petData);
        // Map the fetched data to the desired structure
        pets.data = petData.map(pet => ({
            petName: pet.pet_name,
            image: pet.image,
            description: pet.description,
            age: pet.age,
            breed: pet.breed,
            size: pet.size,
            gender: pet.gender,
            shelter: {
                name: pet.shelter_name,
                place: pet.shelter_place,
                phone: pet.shelter_phone,
            },
            volunteer: {
                id: pet.volunteer_id,
                name: pet.volunteer_name,
            },
            category: pet.category || 'Others' // Default category
        }));

        console.log(pets); // Output the pets object to the console for verification
    } catch (error) {
        console.error('Error fetching pet data:', error);
    }
}

// Call the function to fetch pets
fetchPets();
console.log(pets);
