<?php
// fetch_teacher_data.php

$host = "localhost"; // Your database host
$username = "root"; // Your database username
$password = ""; // Your database password
$dbname = "students"; // Your database name

// Create connection
$conn = new mysqli($host, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$teacherId = $_GET['teacherId'];

// Query to fetch teacher data based on teacherId
$sql = "SELECT subject_name, classroom,time,attendance FROM teachers WHERE rollno = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $teacherId);
$stmt->execute();
$stmt->bind_result($teacherName, $phoneNumber, $address);
$stmt->fetch();

// Return data as JSON
$response = array();
if ($teacherName) {
    $response['teacher_name'] = $teacherName;
    $response['phone_number'] = $phoneNumber;
    $response['address'] = $address;
} else {
    $response['error'] = 'Teacher not found';
}

echo json_encode($response);

$stmt->close();
$conn->close();
?>
