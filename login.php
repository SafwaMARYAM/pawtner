<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Page</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .flex-container {
            display: flex;
            border-radius: 8px;
            max-width: 620px;
            padding: 20px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        .card {
            margin: 1em 50px 0px 0px;
        }
        .signin h1 {
            margin: 50px 0px 25px 0px;
        }
        p{
            text-align: center;
            margin: 20px auto;
            margin-bottom: 50px;
        }
    </style>
</head>
<body>
    <div class="flex-container">
            <?php
                $pet_id = '';
                if (isset($_GET['card'])) {
                    $card = $_GET['card'];
                    echo "<div class='card'> $card </div>";
                }
                if (isset($_GET['pet_id'])) {
                    $pet_id = $_GET['pet_id'];
                }
            ?>
        <div class="signin">
            <?php
                // Function to check if current time is within working hours
                function isWithinWorkingHours($workingHours) {
                    // Set the timezone to Indian Standard Time (IST)
                    date_default_timezone_set('Asia/Kolkata');

                    // Get the current date and time
                    $currentDateTime = new DateTime();

                    // Get the current day of the week
                    $currentDay = strtolower($currentDateTime->format('l')); // e.g., "monday"

                    // Check if today is a working day and within working hours
                    if (isset($workingHours[$currentDay])) {
                        $currentTime = $currentDateTime->format('H:i');

                        // Check if current time is within working hours
                        $start = new DateTime($workingHours[$currentDay]['start']);
                        $end = new DateTime($workingHours[$currentDay]['end']);

                        return $currentTime >= $start->format('H:i') && $currentTime <= $end->format('H:i');
                    }

                    return false; // Not a working day
                }
                $workingHours = [
                'monday' => ['start' => '09:00', 'end' => '17:00'],
                'tuesday' => ['start' => '09:00', 'end' => '17:00'],
                'wednesday' => ['start' => '09:00', 'end' => '17:00'],
                'thursday' => ['start' => '09:00', 'end' => '17:00'],
                'friday' => ['start' => '09:00', 'end' => '17:00'],
                'saturday' => ['start' => '10:00', 'end' => '14:00'],
                'sunday' => ['start' => 'closed', 'end' => 'closed']
                ];

                if ($_SERVER["REQUEST_METHOD"] == "POST") {

                    if(isWithinWorkingHours($workingHours) || true){
                        require 'db_conn.php';

                        $name = htmlspecialchars($_POST["name"]); // Sanitize input
                        $phone = htmlspecialchars($_POST["phone"]); // Sanitize input
                        $pet_id = htmlspecialchars($_POST["pet_id"]);

                        if (!empty($name) && !empty($phone) && !empty($pet_id)) {
                            $stmt = $conn->prepare("INSERT INTO appointments (pet_id, customer_name, customer_number) VALUES (?, ?, ?)");
                            $stmt->bind_param("iss", $pet_id, $name, $phone);
                        
                            try {
                                $stmt->execute();
                            } catch(mysqli_sql_exception $e) {
                                echo   "<div class='text-content'>
                                            <h1 class='login-head'>Oops! Database Error</h1>
                                            <p>Pet has already been appointed for Adoption or Server Failed</p>
                                        </div>";
                                $stmt->close();
                                $conn->close();
                                exit();
                            }
                            $stmt = $conn->prepare("SELECT shelters.name AS name, shelters.phone AS phone FROM pets JOIN shelters ON pets.shelter_id = shelters.shelter_id where pet_id = ?");
                            $stmt->bind_param("i",$pet_id);
                            $stmt->execute();
                            $result = $stmt->get_result();

                            if ($result->num_rows === 1) {
                                $row = $result->fetch_assoc();
                                
                                echo   "<div class='text-content'>
                                            <h1 class='login-head'>Welcome $name!</h1>
                                            <p>Our Volunteers will contact you soon for your appointment.</p>
                                            <p>If not, Contact <b>" . $row['name'] . "</b>(Phone no: " . $row['phone'] . ") to confirm your appointment.</p>
                                        </div>";
                            }
                            $stmt->close();
                        } else {
                            echo   "<div class='text-content'>
                                        <h1 class='login-head'>Oops! Missing Data</h1>
                                        <p>Please fill in all required fields.</p>
                                    </div>";
                        }
                        $conn->close();
                    } else {
                        echo   "<div class='text-content'>
                                        <h1 class='login-head'>We are Closed for today</h1>
                                        <p>Come back any weekday from 9 to 5</p>
                                </div>";
                    }
                } else {
                    echo   "<div id='form'>
                                <h1 class='login-head'>Enter your details</h1>
                                <form action='login.php' method='POST'>
                                    <input type='hidden' name='pet_id' value='" . htmlspecialchars($pet_id) . "'>  <!-- Hidden input for card -->
                                    <div class='input-group'>
                                        <label for='name'>Name</label>
                                        <input type='text' name='name' id='name' required>
                                    </div>
                                    <div class='input-group'>
                                        <label for='phone'>Phone No.</label>
                                        <input type='tel' pattern='\d{10}' maxlength='10' name='phone' id='phone' placeholder='Enter 10-digit phone number' required>
                                    </div>
                                    <button class='form-submit' type='submit'>Login</button>
                                </form>
                            </div>";
                }
            ?>
        </div>
    </div>
</body>
</html>

