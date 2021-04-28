<?php
	
	
	$host='localhost';
	$user='root';
	$password='admin';
	$db='facturacion';
	
	$conection = @mysqli_connect($host,$user,$password,$db);

	
	
	if(!$conection)
	{
		echo"fallo en la conection";
	}
	


?>