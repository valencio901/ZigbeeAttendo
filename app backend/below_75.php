<?php
$host = "localhost"; // Change if hosted elsewhere
$user = "root"; // Database username
$password = ""; // Database password

// Ensure the className parameter is set
if (!isset($_GET['className']) || empty($_GET['className'])) {
    die(json_encode(["error" => "className is required"]));
}

$database = $_GET['className']; // Get the database name from the GET request
$database = str_replace(' ', '_', $database); // Replace spaces with underscores in the database name

// Create connection
$conn = new mysqli($host, $user, $password);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// Select the database
if (!$conn->select_db($database)) {
    die(json_encode(["error" => "Database not found: " . $database]));
}

// SQL query to fetch rollno, subject, total lectures, and attended lectures (removed phone numbers)
$sql = "
    SELECT 
        a.rollno, 
        s.name, 
        a.subject, 
        COUNT(*) AS total_lectures, 
        SUM(CASE WHEN a.attendance = 'Present' THEN 1 ELSE 0 END) AS attended_lectures,
        (SUM(CASE WHEN a.attendance = 'Present' THEN 1 ELSE 0 END) / COUNT(*) * 100) AS attendance_percentage
    FROM attendance a
    JOIN students s ON a.rollno = s.rollno  
    GROUP BY a.rollno, a.subject
    HAVING attendance_percentage < 75
";

// Execute query
$result = $conn->query($sql);

// Initialize an array to store the results
$data = array();

// Check if results exist
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = array(
            'rollno' => $row['rollno'],
            'name' => $row['name'],
            'subject' => $row['subject'],
            'total_lectures' => $row['total_lectures'],
            'attended_lectures' => $row['attended_lectures'],
            'attendance_percentage' => number_format($row['attendance_percentage'], 2),
        );
    }
} else {
    $data = ["message" => "No students found with attendance below 75%."];
}

// Close connection
$conn->close();

// Set content type to JSON
header('Content-Type: application/json');

// Return the data as a JSON response
echo json_encode($data);
?>
