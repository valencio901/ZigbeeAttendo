<?php
// Set your database connection details
$host = 'localhost'; // Database host
$username = 'root'; // Database username
$password = ''; // Database password

// List of databases to check (you can add more if needed)
$databases = ['fybca_a', 'fybca_b']; // Add your databases here

// Connect to MySQL
$conn = new mysqli($host, $username, $password);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get today's date
$today = date('Y-m-d');

// Initialize total present count
$total_present = 0;

// Loop through each database and check attendance
foreach ($databases as $database) {
    // Select the database
    $conn->select_db($database);

    // Query to count how many students were present today
    $query = "SELECT COUNT(DISTINCT rollno) AS present_count 
              FROM attendance 
              WHERE attendance = 'Present' AND date = '$today'";

    // Execute the query
    $result = $conn->query($query);

    if ($result) {
        // Fetch the count
        $row = $result->fetch_assoc();
        $total_present += $row['present_count']; // Add to total present count
    } else {
        echo "Error: " . $conn->error . "<br>";
    }
}

// Close the connection
$conn->close();

// Output the total number of students present today
echo "Total students present today: $total_present";
?>
