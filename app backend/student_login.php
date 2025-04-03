<?php
// Retrieve POST data
$data = json_decode(file_get_contents("php://input"));

$rollno = $data->rollno;
$password = $data->password;
$class = $data->db; // Class value to determine which database to use

// Establish a database connection dynamically based on the 'class' value
$servername = "localhost";  // Your database server
$username = "root"; // Your database username
$dbpassword = ""; // Your database password

try {
    // Connect to MySQL
    $pdo = new PDO("mysql:host=$servername;dbname=$class", $username, $dbpassword);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Prepare the query to check if the student exists in the database
    $stmt = $pdo->prepare("SELECT * FROM students WHERE rollno = :rollno AND password = :password");
    $stmt->bindParam(':rollno', $rollno);
    $stmt->bindParam(':password', $password);
    $stmt->execute();

    // Check if the student exists
    $student = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($student) {
        // Successful login
        echo json_encode(['status' => 'success', 'message' => 'Login successful']);
    } else {
        // Failed login
        echo json_encode(['status' => 'failure', 'message' => 'Invalid credentials']);
    }
} catch (PDOException $e) {
    // If the connection or query fails
    echo json_encode(['status' => 'error', 'message' => 'Error connecting to database: ' . $e->getMessage()]);
}
?>
