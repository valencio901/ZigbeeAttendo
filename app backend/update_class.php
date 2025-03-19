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
$substituteTeacherName = $_POST['substituteTeacherName'] ?? '';
$type = $_POST['type'] ?? '';
$batch = isset($_POST['batch']) && $_POST['batch'] !== 'No Batch' ? $_POST['batch'] : null;

if (empty($teacherName)) {
    echo json_encode(["success" => false, "message" => "Teacher Name is required"]);
    exit();
}

if(empty($substituteTeacherName)){
    $substituteTeacherName=$teacherName;
}

try {
    foreach ($databases as $db) {
        $conn = new mysqli($servername, $username, $password, $db);

        if ($conn->connect_error) {
            continue;
        }

        // Prepare SQL query
        $sql = "UPDATE monday SET classroom = ?, lecture = ?, start_time = ?, end_time = ?, teacher = ?, type = ?, batch = ? WHERE teacher = ?";
        $stmt = $conn->prepare($sql);

        // If batch is null, bind NULL value correctly
        if ($batch === null) {
            $stmt->bind_param("sssssssi", $classroom, $lecture, $start_time, $end_time, $substituteTeacherName, $type, $batch, $teacherName);
        } else {
            $stmt->bind_param("ssssssss", $classroom, $lecture, $start_time, $end_time, $substituteTeacherName, $type, $batch, $teacherName);
        }

        $stmt->execute();
        $stmt->close();
        $conn->close();
    }

    echo json_encode(["success" => true, "message" => "Class updated successfully"]);

} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
}
?>
