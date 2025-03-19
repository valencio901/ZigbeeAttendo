<?php
$host = "localhost";
$user = "root";
$password = "";  // Replace with your database password
$dbname = "students";

// Create connection
$conn = new mysqli($host, $user, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Retrieve POST data
$rollno = $_POST['rollno'];
$password = password_hash($_POST['password'], PASSWORD_BCRYPT);
$name = $_POST['name'];
$class = $_POST['class'];
$classroom = $_POST['classroom'];
$college = $_POST['college'];

// Insert query
$sql = "INSERT INTO students (rollno, password, name, class, classroom, college) 
        VALUES ('$rollno', '$password', '$name', '$class', '$classroom', '$college')";

if ($conn->query($sql) === TRUE) {
    echo "Registration successful.";
} else {
    echo "Error: " . $conn->error;
}

$conn->close();
?>
