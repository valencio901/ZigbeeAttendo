<?php
// Database configuration
$servername = "localhost"; // or your database server
$username = "root"; // database username
$password = ""; // database password

$className = isset($_POST['className']) ? $_POST['className'] : 'default_class';  // Default class if not provided

$dbname = $className;

$dbname = str_replace(" ", "_", $dbname);

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// SQL to fetch timetable data for each day
$sql = [
    "monday" => "SELECT * FROM monday",
    "tuesday" => "SELECT * FROM tuesday",
    "wednesday" => "SELECT * FROM wednesday",
    "thursday" => "SELECT * FROM thursday",
    "friday" => "SELECT * FROM friday",
    "saturday" => "SELECT * FROM saturday"
];

$response = [];

foreach ($sql as $day => $query) {
    $result = $conn->query($query);
    if ($result->num_rows > 0) {
        // Fetch all rows as an associative array
        while($row = $result->fetch_assoc()) {
            $response[$day][] = $row;
        }
    } else {
        $response[$day] = [];
    }
}

$conn->close();

// Set Content-Type header to JSON
header('Content-Type: application/json');
echo json_encode($response);
?>
