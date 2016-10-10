<?php
    // Get the htags from the variables/htags directory. Ignore anything that
    // starts with a '.'
    $htags = preg_grep('/^([^.])/', scandir ( "../variables/htags" ));
    echo json_encode($htags);
 ?>
