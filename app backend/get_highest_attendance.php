<?php
// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$connection = new mysqli($servername, $username, $password);

// Check connection
if ($connection->connect_error) {
    die("Connection failed: " . $connection->connect_error);
}

// List of databases to check
$databases = ['tybca_a'];  // Add your databases here

// Get the current month and year
$currentMonth = date('m');
$currentYear = date('Y');

// Array to store attendance data for each date
$attendanceData = [];
$totalStudents = 0;  // To store the total unique students

// Iterate through each database in the provided list
foreach ($databases as $databaseName) {
    // Select the database
    $connection->select_db($databaseName);

    // Check if the 'attendance' table exists in the current database
    $sqlCheckTable = "SHOW TABLES LIKE 'attendance'";
    $tableResult = $connection->query($sqlCheckTable);

    if ($tableResult->num_rows > 0) {
        // Query to get attendance counts for each unique rollno per date where attendance = 'Present' for the current month
        $sql = "
            SELECT date, rollno, COUNT(*) as attendance_count
            FROM attendance
            WHERE MONTH(date) = $currentMonth AND YEAR(date) = $currentYear AND attendance = 'Present'
            GROUP BY date, rollno
        ";

        $resultAttendance = $connection->query($sql);

        if ($resultAttendance->num_rows > 0) {
            // Aggregate attendance data by date and count unique students
            while ($rowAttendance = $resultAttendance->fetch_assoc()) {
                $attendanceDate = $rowAttendance['date'];
                $attendanceCount = 1; // Count each rollno once per date

                // Add to the overall attendance data (if date already exists, increment it)
                if (isset($attendanceData[$attendanceDate])) {
                    $attendanceData[$attendanceDate] += $attendanceCount;
                } else {
                    $attendanceData[$attendanceDate] = $attendanceCount;
                }
            }

            // Count the total unique students in the attendance table for the current month
            $sqlTotalStudents = "
                SELECT COUNT(DISTINCT rollno) AS total_students
                FROM attendance
                WHERE MONTH(date) = $currentMonth AND YEAR(date) = $currentYear
            ";

            $resultTotalStudents = $connection->query($sqlTotalStudents);
            if ($resultTotalStudents->num_rows > 0) {
                $rowTotal = $resultTotalStudents->fetch_assoc();
                $totalStudents += $rowTotal['total_students'];
            }
        }
    } else {
        // Table does not exist, add error in JSON response
        $attendanceData[] = ['error' => "Database: $databaseName - 'attendance' table not found."];
    }
}

// Prepare data for each date in the current month
$responseData = [];

foreach ($attendanceData as $date => $count) {
    // Calculate the percentage of students who came to college for the current date
    $attendancePercentage = 0;
    if ($totalStudents > 0) {
        $attendancePercentage = ($count / $totalStudents) * 100;
    }

    // Store the result for this date
    $responseData[] = [
        'date' => $date,
        'attendance_count' => $count,
        'attendance_percentage' => round($attendancePercentage, 2)
    ];
}

// Set the content type to application/json for proper JSON response
header('Content-Type: application/json');

// Print the JSON response with attendance data for each date
echo json_encode($responseData);

$connection->close();
?>
