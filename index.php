<?php
session_start();
if(!empty($_SESSION['active'] ))
{
	header('location: sistema/');
}else{
	
	$alert='';
	if(!empty($_POST))// este post es para saber si el metodo POST esta funncionando
	{
		if(empty($_POST['usuario']) || empty($_POST['clave']))// este es para los imput si estan vacion
		{
			$alert='Ingrese su usario y su clave'; //mensaje para los imput si estan vacios
		}else 
		{
			require_once "conexion.php"; // requiere una conexion a la vace de datos y extrameso del archivo conexion
			
			$user = mysqli_real_escape_string($conection,$_POST['usuario']); // creamos variables para luego llevar a la consulta de base de datos
			$pass = md5(mysqli_real_escape_string($conection,$_POST['clave']));// creamos variables para luego llevar a la consulta de base de datos
		
			$query = mysqli_query($conection,"SELECT u.idusuario, u.nombre, u.correo, u.usuario, 										r.idrol, r.rol
											  FROM usuario u
											  INNER JOIN rol r
											  ON u.rol = r.idrol 
											  WHERE u.usuario='$user' and u.clave='$pass'");// consulta a la base de datos
			mysqli_close($conection);
			$result = mysqli_num_rows($query);//esto nos devuelve un numero
			print_r($result);
			if($result > 0)
			{
				$data = mysqli_fetch_array($query);
				
				$_SESSION['active'] = true;
				$_SESSION['idUser'] = $data['idusuario'];
				$_SESSION['nombre'] = $data['nombre'];
				$_SESSION['email'] = $data['correo'];
				$_SESSION['user'] = $data['usuario'];
				$_SESSION['rol'] = $data['idrol'];
				$_SESSION['rol_name'] = $data['rol'];
				header('location: sistema/');
			}
			else{
				$alert ='El usurio o contraseña son incorrectos';
				session_destroy();
			}
		}
	}
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Tienda Online</title>
	<link rel="stylesheet" type="text/css" href="css/styles.css">
</head>
<body>
<section id="container">
	<form action="" method="post">
	<h3>Iniciar Sesion</h3>
	<img src="img/candado.png" alt="Login" width="200" height="200">
	<input type="text" name="usuario" placeholder="Usuario">
	<input type="password" name="clave" placeholder="Contraseña">
	<div class="alert"><?php echo isset($alert) ? $alert : '';?></div>
	<input type="submit" Value="INGRESAR">
	</form>
</section>
</body>
</html>
















