<?php

header("Content-Type: application/json");

// Database credentials
$server = "localhost";
$username = "root";
$password = "";

// Check if dbname is provided
if (!isset($_GET['dbname'])) {
    echo json_encode(["error" => "Database name is required"]);
    exit();
}

// Replace spaces with underscores in database name
$database = str_replace(" ", "_", $_GET['dbname']);

// Connect to MySQL
$conn = new mysqli($server, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    echo json_encode(["error" => "Connection failed: " . $conn->connect_error]);
    exit();
}

// Days of the week
$weekdays = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday"];

$schedule = [];

foreach ($weekdays as $day) {
    $query = "SELECT lecture, teacher, start_time, end_time, classroom FROM $day";
    $result = $conn->query($query);

    if ($result) {
        $lectures = [];
        while ($row = $result->fetch_assoc()) {
            $lectures[] = $row;
        }
        $schedule[$day] = $lectures;
    } else {
        $schedule[$day] = []; // Instead of an error message, return an empty list
    }
}

// Close connection
$conn->close();

// Return JSON response
echo json_encode($schedule);

?>
