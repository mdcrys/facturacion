<?php


session_start();

//si es diefernte de 1 o 2 visualize el menu
if($_SESSION['rol']!= 1 and $_SESSION['rol']!= 2)
{
	header("location: ./");
} 

include "../conexion.php";


// aqui se hace el metodo post, eso quiere decir cuando se hace click en el boton guardar siempre y cuando el form este en method="post"

if(!empty($_POST))
{
	$alert='';
	// para validar los campos vacios 
	if(empty($_POST['proveedor'] ) || empty($_POST['contacto'] ) || empty($_POST['telefono']) || empty($_POST['direccion']))
	{
		// mensaje de campos vacios
		$alert ='<p class="msg_error"> Todos los campos son obligatorios. </p>';
	}else{

		//llenando los campos mediante POST
		//variable 	//lo que va en el text lo guardamos 
		$proveedor		= $_POST['proveedor'];
		$contacto  	    = $_POST['contacto'];			
		$telefono 	    = $_POST['telefono'];
		$direccion      = $_POST['direccion'];
		$usuario_id 	= $_SESSION['idUser'];
		//$dateadd = $_POST['dateadd'];
		

		$query_insert = mysqli_query($conection, "INSERT INTO proveedor(proveedor,contacto,telefono,direccion,usuario_id)
														VALUES ('$proveedor','$contacto','$telefono','$direccion','$usuario_id')");//,'now(dateadd)
			if($query_insert){
				$alert ='<p class="msg_save">Proveedor creado correctamente.</p>';
			}else{
				$alert ='<p class="msg_error">Error al crear el Proveedor.</p>';
			}
		
		}

		//echo"SELECT * FROM usuario WHERE usuario = '$user' OR correo ='$email'";

		mysqli_close($conection);
		
	}


?>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<?php include "includes/scripts.php"?>
	<title>Registro Proveedor</title>
</head>
<body>
	<?php include "includes/header.php"?>
	<section id="container">
		<div class="form_register">
			<h1><i class="far fa-building"></i> Resgistro Proveedor</h1>
			<hr>
			<div class="alert"><?php echo isset($alert) ?$alert : ''; ?></div>
			<form action="" method="post">
				<label for="proveedor">Proveedo</label>
				<input type="text" name="proveedor" id="proveedor" placeholder="Nombre del proveedor">
				<label for="contacto">Contacto</label>
				<input type="text" name="contacto" id="contacto" placeholder="nombre completo del contacto">
				<label for="telefono">Telefono</label>
				<input type="number" name="telefono" id="telefono" placeholder="Telefono">
				<label for="direccion">Direccion</label>
				<input type="text" name="direccion" id="usuario" placeholder="Direccion">
				<button type="submit" class="btn_save"><i class="far fa-save fa-lg"></i>Guardar Proveedor</button>
			</form>
		</div>
		
	</section>
	<?php include "includes/footer.php"?>
</body>
</html>