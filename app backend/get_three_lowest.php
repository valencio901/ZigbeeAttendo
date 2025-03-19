<?php
$servername = "localhost"; // Your database server
$username = "root"; // Your MySQL username
$password = ""; // Your MySQL password
$databases = ["tybca_a", "tybca_b", "sybca_a","sybca_b","fybca_a","fybca_b"]; // List of databases you want to check

// Function to calculate attendance percentage for each database
function getAttendancePercentage($dbname) {
    global $servername, $username, $password;

    // Create connection
    $conn = new mysqli($servername, $username, $password, $dbname);

    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    // SQL query to get total attendance and count present/absent
    $sql = "SELECT COUNT(*) AS total, 
                   SUM(CASE WHEN attendance = 'Present' THEN 1 ELSE 0 END) AS present,
                   SUM(CASE WHEN attendance = 'Absent' THEN 1 ELSE 0 END) AS absent
            FROM attendance";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        // Get the first row of the result
        $row = $result->fetch_assoc();
        $total = $row['total'];
        $present = $row['present'];
        $absent = $row['absent'];

        if ($total > 0) {
            // Calculate percentage
            $presentPercentage = ($present / $total) * 100;

            // Return the result as an array (database name and attendance percentage)
            return [
                'database' => $dbname,
                'attendance_percentage' => $presentPercentage
            ];
        }
    }

    $conn->close();
    return null; // In case of no data or error
}

// Array to store attendance data of all databases
$attendanceData = [];

// Loop through each database and calculate attendance
foreach ($databases as $database) {
    $attendance = getAttendancePercentage($database);
    if ($attendance) {
        $attendanceData[] = $attendance;
    }
}

// Sort the attendance data by the 'attendance_percentage' in ascending order (for lowest attendance)
usort($attendanceData, function($a, $b) {
    return $a['attendance_percentage'] - $b['attendance_percentage'];
});

// Display the top 3 databases with the lowest attendance
echo "<h2>Top 3 Databases with the Lowest Attendance:</h2>";
for ($i = 0; $i < min(3, count($attendanceData)); $i++) {
    $database = $attendanceData[$i];
    echo "Rank " . ($i + 1) . ": " . $database['database'] . " - " . round($database['attendance_percentage'], 2) . "%<br>";
}
?>
