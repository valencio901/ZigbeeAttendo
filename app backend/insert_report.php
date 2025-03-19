<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "admin"; // Update with your database name

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get the data from the request
$rollno = $_POST['rollno'];
$class = $_POST['class'];
$classroom = $_POST['classroom'];
$report = $_POST['report'];

// Insert the data into the table
$sql = "INSERT INTO student_report (rollno, class, classroom, report) 
        VALUES ('$rollno', '$class', '$classroom', '$report')";

if ($conn->query($sql) === TRUE) {
    echo "Report successfully submitted";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>
