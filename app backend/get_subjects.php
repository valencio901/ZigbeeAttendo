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

// Get teacherId from the request
if (isset($_GET["teacherId"])) {
    $teacherId = $_GET["teacherId"];

    // Fetch distinct subjects taught by the teacher
    $sql = "SELECT DISTINCT subject FROM attendance WHERE teacher_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $teacherId);
    $stmt->execute();
    $result = $stmt->get_result();

    $subjects = [];
    while ($row = $result->fetch_assoc()) {
        $subjects[] = $row["subject"];
    }

    echo json_encode(["subjects" => $subjects]);
} else {
    echo json_encode(["error" => "Missing teacherId parameter"]);
}

$conn->close();
?>
