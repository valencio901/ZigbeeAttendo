<?php
header("Content-Type: application/json");

$servername = "localhost";
$username = "root";
$password = "";

// List of databases
$databases = ["tybca_a"]; // Add more databases as needed

$teacherName = $_GET['teacherName'];

$attendanceData = [];

// Create a connection to MySQL server (without selecting a database)
$conn = new mysqli($servername, $username, $password);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// Loop through each database
foreach ($databases as $database) {
    // Select the database dynamically
    $conn->select_db($database);

    // Query the attendance table for the given teacher
    $sql = "SELECT rollno, attendance, date, subject, time, classroom FROM attendance WHERE teacher = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $teacherName);
    $stmt->execute();
    $result = $stmt->get_result();

    // Fetch all records and merge them into the response array
    while ($row = $result->fetch_assoc()) {
        $row["database"] = $database; // Optional: Indicate which database the record is from
        $attendanceData[] = $row;
    }

    $stmt->close();
}

$conn->close();

// Return the merged JSON response
echo json_encode(["attendanceRecords" => $attendanceData], JSON_PRETTY_PRINT);
?>
