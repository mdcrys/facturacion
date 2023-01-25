<?php


session_start();

include "../conexion.php";

if(!empty($_POST))
{
	$alert='';
	// para validar los campos vacios 
	if(empty($_POST['nombre'] ) || empty($_POST['telefono']) || empty($_POST['direccion']))
	{
		// mensaje de campos vacios
		$alert ='<p class="msg_error"> Todos los campos son obligatorios. </p>';
	}else{

		//llenando los campos mediante POST
		$nit    =$_POST['nit'];
		$nombre = $_POST['nombre'];
		$telefono  = $_POST['telefono'];
		$direccion   = $_POST['direccion'];
		$usuario_id = $_SESSION['idUser'];
		//$dateadd = $_POST['dateadd'];
		

		$result = 0;

		//is_numeric = si es numerico
		if(is_numeric($nit) and $nit!=0)
		{
			$query = mysqli_query($conection, "SELECT * FROM cliente WHERE nit = '$nit'");
			$result = mysqli_fetch_array($query);
			
		}
		//consulta para verificar si existe numero de cedula 
		if($result > 0)
		{
			$alert ='<p class="msg_error">El numero de nit ya existe.</p>';
		}else{
			$query_insert = mysqli_query($conection, "INSERT INTO cliente(nit,nombre,telefono,direccion,usuario_id,dateadd)
														VALUES ('$nit','$nombre','$telefono','$direccion','$usuario_id','now(dateadd)')");
			if($query_insert){
				$alert ='<p class="msg_save">Cliente creado correctamente.</p>';
				header("location: ./lista_clientes.php");
			}else{
				$alert ='<p class="msg_error">Error al crear el Cliente.</p>';
			}
		
		}

		//echo"SELECT * FROM usuario WHERE usuario = '$user' OR correo ='$email'";

		mysqli_close($conection);
		
	}
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<?php include "includes/scripts.php"?>
	<title>Registro Cliente</title>
</head>
<body>
	<?php include "includes/header.php"?>
	<section id="container">
		<div class="form_register">
			<h1>Resgistro Cliente</h1>
			<hr>
			<div class="alert"><?php echo isset($alert) ?$alert : ''; ?></div>
			<form action="" method="post">
				<label for="nit">NIT</label>
				<input type="number" name="nit" id="nit" placeholder="NIT">
				<label for="nombre">Nombre</label>
				<input type="text" name="nombre" id="nombre" placeholder="nombre completo">
				<label for="telefono">Telefono</label>
				<input type="number" name="telefono" id="telefono" placeholder="Telefono">
				<label for="direccion">Direccion</label>
				<input type="text" name="direccion" id="usuario" placeholder="Direccion">
				<input type="submit" value="Guardar Cliente" class="btn_save">
			</form>
		</div>
		
	</section>
	<?php include "includes/footer.php"?>
</body>
</html>