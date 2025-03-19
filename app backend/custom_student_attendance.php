<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");

$servername = "localhost";
$username = "root"; // Change as per your DB credentials
$password = ""; // Change as per your DB credentials
$database = isset($_GET['class']) ? $_GET['class'] : ''; // Get class name from request

if (empty($database)) {
    echo json_encode(["error" => "Class name is required"]);
    exit();
}

// Create connection
$conn = new mysqli($servername, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// Get input parameters
$rollno = isset($_GET['rollno']) ? intval($_GET['rollno']) : 0;
$subject = isset($_GET['subject']) ? $_GET['subject'] : '';
$start_date = isset($_GET['start_date']) ? $_GET['start_date'] : '';
$end_date = isset($_GET['end_date']) ? $_GET['end_date'] : '';

if ($rollno == 0 || empty($subject) || empty($start_date) || empty($end_date)) {
    echo json_encode(["error" => "Missing required parameters"]);
    exit();
}

// Fetch attendance records within the date range
$sql = "SELECT date, attendance FROM attendance 
        WHERE rollno = ? AND subject = ? 
        AND date BETWEEN ? AND ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("isss", $rollno, $subject, $start_date, $end_date);
$stmt->execute();
$result = $stmt->get_result();

$attendanceRecords = [];
while ($row = $result->fetch_assoc()) {
    $attendanceRecords[] = $row;
}

// Count total lectures within the date range for the specific rollno
// Count total lectures within the date range for the specific rollno and subject
$sql_count = "SELECT COUNT(DISTINCT date) as total FROM attendance 
              WHERE rollno = ? AND subject = ? 
              AND date BETWEEN ? AND ?";
$stmt_count = $conn->prepare($sql_count);
$stmt_count->bind_param("ssss", $rollno, $subject, $start_date, $end_date);
$stmt_count->execute();
$result_count = $stmt_count->get_result();
$totalLectures = $result_count->fetch_assoc()['total'];

// Fetch attendance records
$sql = "SELECT date, attendance FROM attendance 
        WHERE rollno = ? AND subject = ? 
        AND date BETWEEN ? AND ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ssss", $rollno, $subject, $start_date, $end_date);
$stmt->execute();
$result = $stmt->get_result();

$attendanceRecords = [];
while ($row = $result->fetch_assoc()) {
    $attendanceRecords[] = $row;
}

$response = [
    "attendance" => $attendanceRecords,
    "numLectures" => $totalLectures
];

echo json_encode($response);

// Close connection
$stmt->close();
$stmt_count->close();
$conn->close();
?>
