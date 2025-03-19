<?php
// Define the path where you want to save the uploaded logs
$logFilePath = 'logs/uploaded_log.txt';

// Check if the logData parameter is provided
if (isset($_POST['logData'])) {
    // Get the log data from the POST request
    $logData = $_POST['logData'];

    // Open the log file in append mode
    $logFile = fopen($logFilePath, 'a');
    
    // Check if the file opened successfully
    if ($logFile) {
        // Write the log data to the file
        fwrite($logFile, $logData . "\n");

        // Close the file after writing
        fclose($logFile);

        // Respond back with success message
        echo "Log uploaded successfully!";
    } else {
        // Respond back with an error if the file couldn't be opened
        echo "Error opening log file!";
    }
} else {
    // Respond back with an error if the logData parameter is not found
    echo "No log data received!";
}
?>
