<?php
header('Content-Type: application/json');

$databases = ['tybca_a'];
$host = 'localhost';
$username = 'root';
$password = '';

$totalStudents = [];
$totalPresent = 0;

foreach ($databases as $dbName) {
    $conn = new mysqli($host, $username, $password, $dbName);

    if ($conn->connect_error) {
        die(json_encode(["error" => "Connection failed for $dbName: " . $conn->connect_error]));
    }

    $query = "SELECT DISTINCT rollno, attendance FROM attendance";
    $result = $conn->query($query);

    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $totalStudents[$row['rollno']] = true;
            if (strtolower($row['attendance']) === 'present') {
                $totalPresent++;
            }
        }
    }
    
    $conn->close();
}

$totalCount = count($totalStudents);

echo json_encode([
    "totalCount" => $totalCount,
    "totalPresent" => $totalPresent
]);
?>
