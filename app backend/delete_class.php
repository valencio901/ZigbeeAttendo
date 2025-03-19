<?php
header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "";
$databases = ["tybca_a"]; // Databases to search

$teacherName = $_POST['teacherName'] ?? '';
$classroom = $_POST['classroom'] ?? '';
$lecture = $_POST['lecture'] ?? '';
$start_time = $_POST['start_time'] ?? '';
$end_time = $_POST['end_time'] ?? '';


$deleted = false;

foreach ($databases as $db) {
    $conn = new mysqli($servername, $username, $password, $db);

    if ($conn->connect_error) {
        continue;
    }

    $sql = "DELETE FROM monday WHERE teacher = ? AND classroom = ? AND lecture = ? AND start_time = ? AND end_time = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssss", $teacherName,$classroom,$lecture,$start_time,$end_time);

    if ($stmt->execute()) {
        $deleted = true;
    }

    $stmt->close();
    $conn->close();
}

if ($deleted) {
    echo json_encode(["success" => true, "message" => "Class deleted successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to delete class"]);
}
?>
