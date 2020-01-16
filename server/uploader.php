<?php
    // only accept POST requests!
    if ($_SERVER["REQUEST_METHOD"] !== "POST") {
        http_response_code(401);
        exit;
    }
    // Post data will have token in it. Try to use token - if we get a good response, then this person is good to go!
    $request = json_decode(file_get_contents("php://input"), true);

    if ($request["token"] == null || $request["token"] === "") {
        http_response_code(401);
        exit;
    }

    // try curl request
    $token = $request["token"];
    $URL = 'https://gatech.instructure.com/api/v1/courses?enrollment_type=teacher';
    $HEADER = array('Authorization: Bearer ' . $token);
    $fh = fopen("tmp.json", 'w');
    $curlObj = curl_init();
    curl_setopt($curlObj, CURLOPT_URL, $URL);
    curl_setopt($curlObj, CURLOPT_HTTPHEADER, $HEADER);
    curl_setopt($curlObj, CURLOPT_FILE, $fh);
    curl_exec($curlObj);
    // if not 200, return 403
    $code = curl_getinfo($curlObj)['http_code'];
    curl_close($curlObj);
    fclose($fh);
    if ($code !== 200) {
        http_response_code(403);
        exit;
    }
    $json = json_decode(file_get_contents("tmp.json"), true);

    // try curl request
    $URL = 'https://gatech.instructure.com/api/v1/courses?enrollment_type=ta';
    $fh = fopen("tmp.json", 'w');
    $curlObj = curl_init();
    curl_setopt($curlObj, CURLOPT_URL, $URL);
    curl_setopt($curlObj, CURLOPT_HTTPHEADER, $HEADER);
    curl_setopt($curlObj, CURLOPT_FILE, $fh);
    curl_exec($curlObj);
    // if not 200, return 403
    $code = curl_getinfo($curlObj)['http_code'];
    curl_close($curlObj);
    fclose($fh);
    if ($code !== 200) {
        http_response_code(403);
        exit;
    }
    $json2 = json_decode(file_get_contents("tmp.json"), true);

    $json = array_merge($json, $json2); 

    // check if current course is there. Define by start month:
        // 01 -> SPRING
        // 05 -> SUMMER
        // 08 -> FALL
    // Check that we are currently in that range, inclusive
    $SPRING_START = 1;
    $SUMMER_START = 5;
    $FALL_START = 8;
    $CURR_MONTH = (int) date("m");
    $currSemester = '';
    if ($CURR_MONTH >= $SPRING_START 
        && $CURR_MONTH <= $SUMMER_START) {
        $currSemester = 'SPRING';
    } elseif ($CURR_MONTH >= $SUMMER_START 
        && $CURR_MONTH <= $FALL_START) {
        $currSemester = 'SUMMER';
    } else {
        $currSemester = 'FALL';
    }
    $isValid = false;
    foreach ($json as $idx => $course) {
        // if CS 1371 is found, then good to go
        if (preg_match('/(CS|cs).*1371\w*/', strtolower($course['course_code'])) === 0) {
            continue;
        }
        // check course start date to see what semester (SPRING, SUMMER, FALL).
        // Then, check current month falls in that semester. If it does, let's go; else, die.
        // We can't trust date(), because it won't understand our format:
            // YYYY-MM-DD
        // so always look at 5, 2:

        $courseMonth = (int) substr($course['start_at'], 5, 2);
        if (($courseMonth === $SPRING_START 
            && $currSemester === 'SPRING')
            ||
            ($courseMonth >= $SUMMER_START 
            && $courseMonth <= $FALL_START 
            && $currSemester === 'SUMMER')
            ||
            ($courseMonth === $FALL_START
            && $currSemester === 'FALL')) {
            // we are a TA for this course, which is:
                // CS 1371
                // in the current semester
            // Good to go - valid is true!
            $isValid = true;
            break;
        }
    }
    unlink('tmp.json');

    if (!$isValid) {
        http_response_code(403);
        exit;
    }
    // get data in POST request; write the correct files.
    // JSON; each file has PATH and DATA
    $files = $request["files"];
    for ($i = 0; $i < count($files); $i++) {
        // get path from path
        if (!file_exists(dirname($files[$i]["path"]))) {
            mkdir(dirname($files[$i]["path"]), 0777, true);
        }
        file_put_contents($files[$i]["path"], fopen($files[$i]["data"], 'rb'));
    }
    http_response_code(201);
    exit;
?>
