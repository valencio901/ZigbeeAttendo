<?php
// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "teachers";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get teacher_name from the request
$teacher_name = $_GET['teacher_name'];

// Query to fetch data
$sql = "SELECT teacherName, Attendance, Lecture, classroom, class, 
               CONCAT(start_time, ' - ', end_time) AS lecture_time 
        FROM teacherattendance 
        WHERE teacherName = ?";

// Prepare statement to prevent SQL injection
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $teacher_name);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data);

$stmt->close();
$conn->close();
?>
