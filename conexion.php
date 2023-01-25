<?php
	
	
	$host='localhost';
	$user='root';
	$password='';
	$db='tienda';
	
	$conection = @mysqli_connect($host,$user,$password,$db);

	
	
	if(!$conection)
	{
		echo"fallo en la conection";
	}
	


?>