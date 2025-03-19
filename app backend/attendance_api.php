<?php
$servername = "localhost";
$username = "root";
$password = "";
$databases = ["tybca_a"]; // Add all databases

function getAttendancePercentage($dbname) {
    global $servername, $username, $password;
    $conn = new mysqli($servername, $username, $password, $dbname);
    if ($conn->connect_error) {
        return null;
    }

    $sql = "SELECT COUNT(*) AS total, 
                   SUM(CASE WHEN attendance = 'Present' THEN 1 ELSE 0 END) AS present
            FROM attendance";
    $result = $conn->query($sql);
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $total = $row['total'];
        $present = $row['present'];
        $attendancePercentage = $total > 0 ? ($present / $total) * 100 : 0;
        return ['database' => $dbname, 'attendance_percentage' => $attendancePercentage];
    }
    return null;
}

$attendanceData = [];
foreach ($databases as $database) {
    $attendance = getAttendancePercentage($database);
    if ($attendance) {
        $attendanceData[] = $attendance;
    }
}

// Sort for highest attendance
usort($attendanceData, fn($a, $b) => $b['attendance_percentage'] - $a['attendance_percentage']);
$highestAttendance = array_slice($attendanceData, 0, 3);

// Sort for lowest attendance
usort($attendanceData, fn($a, $b) => $a['attendance_percentage'] - $b['attendance_percentage']);
$lowestAttendance = array_slice($attendanceData, 0, 3);

echo json_encode(["highest" => $highestAttendance, "lowest" => $lowestAttendance]);
?>
