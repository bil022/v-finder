<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

//read json label database as a string
$string = file_get_contents("items.json");

//if there are no items in the json file, print error statement and exit
if ($string === false) {
  echo json_encode("[{\"fcid\": \"Cannot open items.json\"}]");
  exit();
}

//set search variable for use in the foreach loop below(note: these are consecutive ifs, not if else)
$search="";
//check if there is an entry in the search bar, if there is then set the $search variable to that entry(the entry will be a string) 
if (isset($_REQUEST['search']))
  $search = $_REQUEST['search'];
//if the interface between the webserver and PHP is a php command line interface, set search to nk536(debugging)
if (php_sapi_name() === 'cli')
  $search="nk536";
//if the search variable is an empty string, exit 
if ($search == "") {
  print $string;
  exit();
}

//decode the json string into a php object(associative array)
$json_a = json_decode($string, true);
//if the json string is not formatted correctly, print error statement and exit 
if ($json_a === null) {
  echo json_encode("[{\"fcid\": \"Cannot parse items.json\"}]");
  exit();
}

/*
  Search a string for a specified sequence of characters 
  $hay = string to be searched
  $needle = sequence to search for 
  @return = true, false, non-boolean int
*/
function search($hay, $needle) {
  //check if the user is searching with a regular expression sequence
  if (preg_match('/^\/.*\//', $needle)) {
    //return true if the sequence exists inside the string, false otherwise
    if (preg_match($needle, $hay)>0)
      return true;
    return false;
  }
  //searches the string for the sequence, returns false if not found or integer representing index where sequence is if found
  return stripos($hay, $needle);
}

$json_b=array();
//iterate over items in the json  
foreach ($json_a as $item) {
  //reset the flag 
  $hit=0;
  //if the term to be searched for exists in any of the items fields, set flag to true 
  if (search($item['fcid'], $search)!==false) {
    $hit++;
  } else if (search($item['path'], $search)!==false) {
    $hit++;
  } else if (search($item['mdy'], $search)!==false) {
    $hit++;
  } else if (search($item['machine'], $search)!==false) {
    $hit++;
  }
  //if the flag is true, add the found json item to the json_b array and return to the top
  if ($hit>0) {
    $json_b[]=$item;
    continue;
  }

  $files_b=array();
  //search if the term to be searched for exists in the file metadata of an item 
  foreach ($item['files'] as $file) {
    if (search($file['file'], $search)!==false ||
      search($file['size'], $search)!==false ||
      search($file['owner'], $search)!==false ) {
      //if it does, add it to the files_b array
      $hit++;
      array_push($files_b, $file);
    }
  }
  //if the term doesn't exist in this item, go to the next item 
  if ($hit==0) {
    continue;
  }

  //adds files found in files_b to json_b
  $new_item=$item;
  $new_item['hits']=$hit;
  $new_item['files']=$files_b;
  array_push($json_b, $new_item);
}

//returns a json of the items that were found with the search sequence provided
echo json_encode($json_b);
exit();
//everything outside of PHP tags are not interpreted by the php parser; text below looks like lines form items.json-not sure purpose
?>

