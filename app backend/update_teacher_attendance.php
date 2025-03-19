<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Content-Type: application/json");

$host = "localhost"; // e.g., "localhost"
$username = "root";
$password = "";
$dbname = "teachers";

// Create connection
$conn = new mysqli($host, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

// Read JSON input
$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['teacher_name'], $data['classroom'], $data['class'], $data['lecture'], $data['start_time'], $data['end_time'], $data['attendance'])) {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
    exit;
}

// Extract values
$teacher_name = $conn->real_escape_string($data['teacher_name']);
$classroom = $conn->real_escape_string($data['classroom']);
$class = $conn->real_escape_string($data['class']);
$lecture = $conn->real_escape_string($data['lecture']);
$start_time = $conn->real_escape_string($data['start_time']);
$end_time = $conn->real_escape_string($data['end_time']);
$attendance = $conn->real_escape_string($data['attendance']);

// Update attendance in database
$sql = "UPDATE teacherattendance SET Attendance='$attendance' 
        WHERE teacherName='$teacher_name' AND classroom='$classroom' 
        AND class='$class' AND Lecture='$lecture' 
        AND start_time='$start_time' AND end_time='$end_time'";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["status" => "success", "message" => "Attendance updated successfully"]);
} else {
    echo json_encode(["status" => "error", "message" => "Error updating attendance: " . $conn->error]);
}

$conn->close();
?>
