<?php
header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "";
$databases = ["tybca_a"]; // Databases to search

$teacherName = $_GET['teacherName'] ?? '';

if (empty($teacherName)) {
    echo json_encode(["success" => false, "message" => "Teacher name is required"]);
    exit();
}

$resultData = [];

try {
    foreach ($databases as $db) {
        $conn = new mysqli($servername, $username, $password, $db);

        if ($conn->connect_error) {
            continue;
        }


        $sql = "SELECT id, lecture, start_time, end_time, teacher, classroom, batch, type FROM monday WHERE teacher = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("s", $teacherName);
        $stmt->execute();
        $result = $stmt->get_result();

        while ($row = $result->fetch_assoc()) {
            $resultData[] = $row;
        }

        $stmt->close();
        $conn->close();
    }

    if (!empty($resultData)) {
        echo json_encode(["success" => true, "data" => $resultData]);
    } else {
        echo json_encode(["success" => false, "message" => "No classes found"]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
}
?>
