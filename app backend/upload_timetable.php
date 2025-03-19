<?php
if ($_FILES['file']['error'] == UPLOAD_ERR_OK) {
    $tmp_name = $_FILES['file']['tmp_name'];
    $name = $_FILES['file']['name'];
    $upload_dir = 'uploads/';
    $file_path = $upload_dir . basename($name);

    // Move uploaded file to the 'uploads' directory
    if (move_uploaded_file($tmp_name, $file_path)) {
        echo "File uploaded and moved successfully!<br>";

        // Absolute path to Python executable
        $python_path = 'C:/Python312/python.exe';  // Path to your Python installation

        // Absolute path to your Python script
        $script_path = 'C:/xampp/htdocs/process_excel.py';  // Ensure this path is correct

        // Full command to run the Python script with the uploaded file path
        $command = escapeshellcmd("$python_path $script_path $file_path");

        // Capture output of Python script and display it
        $output = shell_exec($command);
        echo "Python script output: " . $output . "<br>";
    } else {
        echo "Failed to move uploaded file.";
    }
} else {
    echo "File upload failed. Error: " . $_FILES['file']['error'];
}
?>
