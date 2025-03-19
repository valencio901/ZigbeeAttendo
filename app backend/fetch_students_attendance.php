<?php
// Get the incoming query parameters from the request
$rollno = $_GET['rollno'];
$class = $_GET['class'];

// Define the current day of the week dynamically
$currentDay = date('l'); // Example: 'Monday', 'Tuesday', etc.
$currentDate = date('Y-m-d');

// Database connection details
$servername = "localhost";  // Change as needed
$username = "root";         // Change as needed
$password = "";             // Change as needed
$dbname = $class;           // Database is dynamic based on the class (e.g., tybca_a)

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

// Ensure the table name is valid
/*$validDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
if (!in_array($currentDay, $validDays)) {
    die(json_encode(["status" => "error", "message" => "Invalid day of the week."]));
}*/

// The table name is dynamically set based on the current day
$tableName = strtolower($currentDay); // 'monday', 'tuesday', etc.

// Query to get the lecture schedule for the current day
$query = "SELECT lecture, start_time, end_time, teacher, classroom, batch, type FROM Monday";
$result = $conn->query($query);

// Check if lectures exist for the day
if ($result->num_rows > 0) {
    $timetable = [];

    while ($row = $result->fetch_assoc()) {
        // Format the time as "HH:MM:SS to HH:MM:SS"
        $formattedTime = $row['start_time'] . " to " . $row['end_time'];

        // Fetch attendance for the current lecture from attendance table
        $attendanceQuery = "SELECT attendance FROM attendance 
                            WHERE rollno = ? 
                            AND subject = ? 
                            AND teacher = ? 
                            AND classroom = ? 
                            AND time = ? 
                            AND date = ?";
        
        $stmt = $conn->prepare($attendanceQuery);
        $stmt->bind_param("isssss", $rollno, $row['lecture'], $row['teacher'], $row['classroom'], 
                          $formattedTime, $currentDate);
        $stmt->execute();
        $attendanceResult = $stmt->get_result();
        $attendanceRow = $attendanceResult->fetch_assoc();

        // Get attendance status, default to 'Not Marked'
        $attendanceStatus = $attendanceRow ? $attendanceRow['attendance'] : 'Not Marked';

        // Add data to the response
        $timetable[] = [
            'lecture' => $row['lecture'],
            'time' => $formattedTime, // Time in "HH:MM:SS to HH:MM:SS" format
            'teacher' => $row['teacher'],
            'classroom' => $row['classroom'],
            'batch' => $row['batch'],
            'type' => $row['type'],
            'attendance' => $attendanceStatus
        ];
    }

    // Return success response with timetable and attendance data
    echo json_encode(["status" => "success", "timetable" => $timetable]);

} else {
    echo json_encode(["status" => "error", "message" => "No timetable data available for today."]);
}

// Close the database connection
$conn->close();
?>
