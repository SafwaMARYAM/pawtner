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
    age VARCHAR(50) NOT NULL,
    breed VARCHAR(50) NOT NULL,
    size ENUM("small","medium","large") NOT NULL,
    gender ENUM("male","female") NOT NULL,
    shelter_id INT NOT NULL,
    volunteer_id INT NOT NULL,
    category ENUM("cat","dog") NOT NULL,
    FOREIGN KEY (shelter_id) REFERENCES Shelters(shelter_id),
    FOREIGN KEY (volunteer_id) REFERENCES Volunteers(volunteer_id)
);
