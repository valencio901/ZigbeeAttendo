<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

$host = "localhost";
$user = "root";
$pass = "";
$class_name = $_POST['class']; // Database name = class name
$rollno = $_POST['rollno'];
$new_attendance = $_POST['attendance'];

$conn = new mysqli($host, $user, $pass, $class_name);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Database connection failed: " . $conn->connect_error]));
}

$sql = "UPDATE attendance SET attendance = ? WHERE rollno = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("si", $new_attendance, $rollno);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Attendance updated successfully"]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to update attendance"]);
}

$stmt->close();
$conn->close();
?>
