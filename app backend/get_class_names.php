<?php
// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "ninth"; // Replace with your actual database name

$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get the teacher ID and subject from the query parameters
$teacherId = $_GET['teacherId'];
$subject = $_GET['subject'];

// Query to get the classes associated with the selected subject
$sql = "
    SELECT DISTINCT class 
    FROM attendance 
    WHERE teacher_id = ? AND subject = ? 
    ORDER BY class;
";

$stmt = $conn->prepare($sql);
$stmt->bind_param("is", $teacherId, $subject);
$stmt->execute();
$result = $stmt->get_result();

$classes = [];

while ($row = $result->fetch_assoc()) {
    $classes[] = $row['class'];
}

$stmt->close();
$conn->close();

// Return the result as JSON
header('Content-Type: application/json');
echo json_encode(['classes' => $classes]);
?>
