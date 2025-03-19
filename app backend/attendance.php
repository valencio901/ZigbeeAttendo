<?php
$servername = "localhost";  // Replace with your server name
$username = "root";         // Replace with your MySQL username
$password = "";             // Replace with your MySQL password
$dbname = "teachers";       // Replace with your database name

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Query to count present and absent attendance
$sql = "SELECT attendance, COUNT(*) as count FROM teacher_attendance WHERE date = CURDATE() GROUP BY attendance";
$result = $conn->query($sql);

$present = 0;
$absent = 0;

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        if ($row['attendance'] == 'P') {
            $present = $row['count'];
        } else if ($row['attendance'] == 'A') {
            $absent = $row['count'];
        }
    }
}

// Calculate total attendance
$total = $present + $absent;

// Calculate percentages
$present_percentage = ($total > 0) ? ($present / $total) * 100 : 0;
$absent_percentage = ($total > 0) ? ($absent / $total) * 100 : 0;

// Create an array to return as JSON
$response = array(
    'present_percentage' => $present_percentage,
    'absent_percentage' => $absent_percentage,
);

// Output JSON response
echo json_encode($response);

// Close connection
$conn->close();
?>
