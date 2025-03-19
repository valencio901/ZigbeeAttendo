<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");

$servername = "localhost";
$username = "root";  // Change as per your database credentials
$password = "";       // Change as per your database credentials
$database = isset($_GET['class']) ? $_GET['class'] : ''; // Get class name from request

if (empty($database)) {
    echo json_encode(["status" => "error", "message" => "Class name is required"]);
    exit();
}

// Create connection
$conn = new mysqli($servername, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

// Get roll number from request
$rollno = isset($_GET['rollno']) ? $_GET['rollno'] : '';

if (empty($rollno)) {
    echo json_encode(["status" => "error", "message" => "Roll number is required"]);
    exit();
}

// Fetch subjects from the attendance table for the given roll number
$sql = "SELECT DISTINCT subject FROM attendance WHERE rollno = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $rollno);
$stmt->execute();
$result = $stmt->get_result();

$subjects = [];
while ($row = $result->fetch_assoc()) {
    $subjects[] = $row['subject'];
}

if (!empty($subjects)) {
    echo json_encode(["status" => "success", "subjects" => $subjects]);
} else {
    echo json_encode(["status" => "error", "message" => "No subjects found"]);
}

// Close connection
$stmt->close();
$conn->close();
?>
