<?php
$host = "localhost"; // Change if your database is hosted elsewhere
$user = "root"; // Replace with your database username
$password = ""; // Replace with your database password

// Get class name from the request
$className = isset($_GET['className']) ? $_GET['className'] : '';

if (empty($className)) {
    die(json_encode(["error" => "className parameter is required"]));
}

$className = str_replace(' ', '_', $className);

$database = $className; // Use className as the database name

// Create connection
$conn = new mysqli($host, $user, $password, $database);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// SQL query to fetch required data
$sql = "SELECT rollno, attendance, time, subject, date,classroom FROM attendance";
$result = $conn->query($sql);

$data = array();

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
}

// Close connection
$conn->close();

// Encode data into JSON and print
header('Content-Type: application/json');
echo json_encode($data, JSON_PRETTY_PRINT);
?>
