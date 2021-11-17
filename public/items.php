<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

$string = file_get_contents("items.json");
if ($string === false) {
  echo json_encode("[{\"fcid\": \"Cannot open items.json\"}]");
  exit();
}

$search="";
if (isset($_REQUEST['search']))
  $search = $_REQUEST['search'];
if (php_sapi_name() === 'cli')
  $search="nk536";
if ($search == "") {
  print $string;
  exit();
}

$json_a = json_decode($string, true);
if ($json_a === null) {
  echo json_encode("[{\"fcid\": \"Cannot parse items.json\"}]");
  exit();
}

function search($hay, $needle) {
  if (preg_match('/^\/.*\//', $needle)) {
    if (preg_match($needle, $hay)>0)
      return true;
    return false;
  }
  return stripos($hay, $needle);
}

$json_b=array();
// $json_b['search']=$hit;
foreach ($json_a as $item) {
  $hit=0;
  if (search($item['fcid'], $search)!==false) {
    $hit++;
  } else if (search($item['path'], $search)!==false) {
    $hit++;
  } else if (search($item['mdy'], $search)!==false) {
    $hit++;
  } else if (search($item['machine'], $search)!==false) {
    $hit++;
  }
  if ($hit>0) {
    $json_b[]=$item;
    continue;
  }

  $files_b=array();
  foreach ($item['files'] as $file) {
    if (search($file['file'], $search)!==false ||
      search($file['size'], $search)!==false ||
      search($file['owner'], $search)!==false ) {
      $hit++;
      array_push($files_b, $file);
    }
  }
  if ($hit==0) {
    continue;
  }

  $new_item=$item;
  $new_item['hits']=$hit;
  $new_item['files']=$files_b;
  array_push($json_b, $new_item);

  /*
  print_r("Begin\n");
  print_r($hit);
  print_r($item);
  print_r("=>");
  print_r(end($json_b));
  print_r("End\n");
  */
}

echo json_encode($json_b);
exit();
?>
[
{ "path": "2021/2021_08_31_IGM/igm-storage2.ucsd.edu/210831_A00953_0389_AHKGHVDSX2", "fcid": "HKGHVDSX2", "mdy": "08/31/2021", "machine": "@A00953", "hasSampleSheet": "false", "hasDoc": "false","files": [
{ "file": "NK539_S12_L001_R1_001.fastq.gz", "size": "1539323922" },	
{ "file": "NK544_S17_L001_R1_001.fastq.gz", "size": "1405794081" },	
{ "file": "NK530_S3_L001_R1_001.fastq.gz", "size": "2006115853" },	[
