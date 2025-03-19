<?php
$directory = "excels/"; // Directory where Excel files are stored
$files = array_diff(scandir($directory), array('..', '.')); // Get all files, excluding '.' and '..'
$fileList = [];
foreach ($files as $file) {
    if (pathinfo($file, PATHINFO_EXTENSION) === 'xlsx') {
        $fileList[] = $file; // Add Excel files to the list
    }
}
echo json_encode($fileList); // Return the list as JSON
?>
