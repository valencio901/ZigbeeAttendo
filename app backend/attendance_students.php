<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

// Database credentials
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tybca_a";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// Query to calculate present and absent percentages
$sql = "SELECT 
            (SUM(CASE WHEN attendance = 'Present' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS present_percentage,
            (SUM(CASE WHEN attendance = 'Absent' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS absent_percentage
        FROM attendance";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode([
        "present_percentage" => round($row["present_percentage"], 2),
        "absent_percentage" => round($row["absent_percentage"], 2)
    ]);
} else {
    echo json_encode(["error" => "No attendance records found"]);
}

$conn->close();
?>
