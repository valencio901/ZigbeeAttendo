<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");

$servername = "localhost"; // Change if your DB host is different
$username = "root"; // Replace with your MySQL username
$password = ""; // Replace with your MySQL password
$database = "ninth"; // Replace with your database name

// Create connection
$conn = new mysqli($servername, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed: " . $conn->connect_error]));
}

// Get teacherId and subject from the request
if (isset($_GET["teacherId"]) && isset($_GET["subject"])) {
    $teacherId = $_GET["teacherId"];
    $subject = $_GET["subject"];
    $class = $_GET["class"];

    // Fetch unique rollnos for the selected subject and teacher
    $sql = "SELECT DISTINCT rollno FROM attendance WHERE teacher_id = ? AND subject = ? AND class = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("iss", $teacherId, $subject, $class);
    $stmt->execute();
    $result = $stmt->get_result();

    $rollnos = [];
    while ($row = $result->fetch_assoc()) {
        // Ensure rollno is treated as a string
        $rollnos[] = strval($row["rollno"]);
    }

    echo json_encode(["rollnos" => $rollnos]);
} else {
    echo json_encode(["error" => "Missing teacherId or subject parameter"]);
}

$conn->close();
?>
