<?php
ini_set('display_errors', 1);

$servername = "127.0.0.1";
$username = rtrim(file_get_contents("/run/secrets/db_user"));
$password = rtrim(file_get_contents("/run/secrets/db_pass"));
$db = "todo";

// Create connection
$conn = new mysqli($servername, $username, $password,$db);

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}
echo "Connected";
$errors = "";
// insert a quote if submit button is clicked
if (isset($_POST['submit'])) {
        if (empty($_POST['task'])) {
                $errors = "You must fill in the task";
        }else{
                $task = $_POST['task'];
                $sql = "INSERT INTO tasks (task) VALUES ('$task')";
                mysqli_query($conn, $sql);
                header('location: index.php?done');
        }
}
if (isset($_GET['del_task'])) {
    $id = $_GET['del_task'];

    mysqli_query($conn, "DELETE FROM tasks WHERE id=".$id);
    header('location: index.php');
}

?>
<html>
<head>
    <title>ToDo List Application PHP and MySQL</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
        <div class="heading">
                <h2 style="font-style: 'Hervetica';">ToDo List Application PHP and MySQL database</h2>
        </div>
        <form method="post" action="index.php" class="input_form">
                <?php if (isset($errors)) { ?>
                <p><?php echo $errors; ?></p>
                <?php } ?>
                <input type="text" name="task" class="task_input">
                <button type="submit" name="submit" id="add_btn" class="add_btn">Add Task</button>
        </form>
        <table>
        <thead>
                <tr>
                        <th>N</th>
                        <th>Tasks</th>
                        <th style="width: 60px;">Action</th>
                </tr>
        </thead>

        <tbody>
                <?php 
                // select all tasks if page is visited or refreshed
                $tasks = mysqli_query($conn, "SELECT * FROM tasks");

                $i = 1; while ($row = mysqli_fetch_array($tasks)) { ?>
                        <tr>
                                <td> <?php echo $i; ?> </td>
                                <td class="task"> <?php echo $row['task']; ?> </td>
                                <td class="delete"> 
                                        <a href="index.php?del_task=<?php echo $row['id'] ?>">x</a> 
                                </td>
                        </tr>
                        <?php $i++; } ?>        
                </tbody>
        </table>
</body>
</html>


