<?php
header("Content-Type: application/json");

// Database connection credentials
$host = "localhost"; // Change if needed
$user = "root"; // Replace with your DB username
$pass = ""; // Replace with your DB password

// List of databases to check
$databases = ["tybca_a"]; // Add all your databases here

// Get teacherName from the request (assuming it's sent via POST)
$teacherName = isset($_POST['teacherName']) ? trim($_POST['teacherName']) : '';

if (empty($teacherName)) {
    echo json_encode(["error" => "No teacherName provided"]);
    exit();
}

$classes = [];

try {
    // Connect to MySQL server
    $conn = new mysqli($host, $user, $pass);
    
    if ($conn->connect_error) {
        throw new Exception("Connection failed: " . $conn->connect_error);
    }

    // Iterate over each database
    foreach ($databases as $db) {
        $query = "SELECT * FROM `$db`.`monday` WHERE `teacher` = ?";
        
        if ($stmt = $conn->prepare($query)) {
            $stmt->bind_param("s", $teacherName);
            $stmt->execute();
            $stmt->store_result();
            
            if ($stmt->num_rows > 0) {
                $classes[] = $db;
            }

            $stmt->close();
        }
    }

    $conn->close();

    // Return the list of databases where the teacher is found
    echo json_encode(["classes" => $classes]);

} catch (Exception $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
