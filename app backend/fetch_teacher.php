<?php
header("Content-Type: application/json");

// Database configuration
$servername = "localhost";
$username = "root"; 
$password = ""; 
$dbname = "teachers";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

if (isset($_GET['teacherId'])) {
    $teacherId = intval($_GET['teacherId']);
    $sql = "SELECT teacher_name, phone_number, address FROM teachers WHERE id = ?";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $teacherId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        echo json_encode($result->fetch_assoc());
    } else {
        echo json_encode(["error" => "No teacher found"]);
    }
    
    $stmt->close();
} else {
    echo json_encode(["error" => "Invalid request"]);
}

$conn->close();
?>
