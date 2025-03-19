<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "teachers";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$sql = "SELECT 
            (SUM(Attendance = 'Present') / COUNT(*)) * 100 AS present_percentage, 
            (SUM(Attendance = 'Absent') / COUNT(*)) * 100 AS absent_percentage
        FROM TeacherAttendance";

$result = $conn->query($sql);
$data = $result->fetch_assoc(); // Fetch a single row

echo json_encode($data);
$conn->close();
?>
