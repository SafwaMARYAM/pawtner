-- Create Shelters Table
CREATE TABLE Shelters (
    shelter_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    place VARCHAR(255) NOT NULL,
    phone VARCHAR(15) NOT NULL
);

-- Create Volunteers Table
CREATE TABLE Volunteers (
    volunteer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Create Pets Table
CREATE TABLE Pets (
    pet_id INT AUTO_INCREMENT PRIMARY KEY,
    pet_name VARCHAR(255) NOT NULL,
    image VARCHAR(255) NOT NULL,
    description TEXT,
    age VARCHAR(50),
    breed VARCHAR(50),
    size VARCHAR(50),
    gender VARCHAR(10),
    shelter_id INT,
    volunteer_id INT,
    category VARCHAR(50),
    FOREIGN KEY (shelter_id) REFERENCES Shelters(shelter_id),
    FOREIGN KEY (volunteer_id) REFERENCES Volunteers(volunteer_id)
);
