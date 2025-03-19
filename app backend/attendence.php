<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tybca_a";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$sql = "SELECT 
            (SUM(attendance = 'Present') / COUNT(*)) * 100 AS present_percentage, 
            (SUM(attendance = 'Absent') / COUNT(*)) * 100 AS absent_percentage
        FROM attendance";

$result = $conn->query($sql);
$data = $result->fetch_assoc(); // Fetch a single row

echo json_encode($data);
$conn->close();
?>
