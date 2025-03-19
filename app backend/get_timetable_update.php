<?php
header("Content-Type: application/json");
$servername = "localhost";  // Change as needed
$username = "root";         // Change as needed
$password = "";             // Change as needed
$dbname = "tybca_a";           // Database is dynamic based on the class (e.g., tybca_a)

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);


$query = "SELECT MAX(last_updated) as last_updated FROM monday";
$result = mysqli_query($conn, $query);

if ($row = mysqli_fetch_assoc($result)) {
    echo json_encode(["status" => "success", "last_updated" => $row['last_updated']]);
} else {
    echo json_encode(["status" => "error"]);
}
?>
