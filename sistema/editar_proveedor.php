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
	//variable para imprir algun mensaje
	$alert='';
	// para validar los campos vacios 
	if(empty($_POST['proveedor'] ) || empty($_POST['contacto'] ) || empty($_POST['telefono']) || empty($_POST['direccion']))
	{
		// mensaje de campos vacios
		$alert ='<p class="msg_error"> Todos los campos son obligatorios. </p>';
	}else{

		//llenando los campos mediante POST
		//variable 	//lo que va en el text lo guardamos 
		$idproveedor	= $_POST['id'];
		$proveedor		= $_POST['proveedor'];
		$contacto  	    = $_POST['contacto'];			
		$telefono 	    = $_POST['telefono'];
		$direccion      = $_POST['direccion'];
		
		$sql_update = mysqli_query($conection,"UPDATE proveedor
															SET proveedor = '$proveedor', contacto = '$contacto', telefono = '$telefono', direccion = '$direccion'
															WHERE codproveedor = $idproveedor");
				
			// validacion para ver si se actualizo correctamente
			
			if($sql_update){
				$alert ='<p class="msg_save">Proveedor actualizado correctamente.</p>';
			}else{
				$alert ='<p class="msg_error">Error al actualizar el Proveedor.</p>';
			}
		}
	
	
}

// Mostrar datos

//si no existe este id
if(empty($_REQUEST['id']))
{
	//nos va a llevar a la lista de los proveedores
	header('Location: lista_proveedor.php');
	mysqli_close($conection);
}
// de lo contratio toma la variable y toma en el idProveedor
$idproveedor = $_REQUEST['id'];

$sql = mysqli_query($conection,"SELECT * FROM proveedor WHERE codproveedor = $idproveedor");
mysqli_close($conection);

//para contar los registros cuantos nos a devuelto
$result_sql = mysqli_num_rows($sql);


// si nos devuelve 0  
if($result_sql == 0)
{
	// que nos envie a lista proveedor 
	header('Location: lista_proveedor.php');

	// caso contrario 
}else{
	
	//toma los datos en un array y guardamos a un variable $data
	while ($data = mysqli_fetch_array($sql)) {
		$idproveedor  = $data['codproveedor'];
		$proveedor	  = $data['proveedor'];
		$contacto     = $data['contacto'];
		$telefono  	  = $data['telefono'];
		$direccion    = $data['direccion'];
	}
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<?php include "includes/scripts.php"?>
	<title>Acturalizar Proveedor</title>
</head>
<body>
	<?php include "includes/header.php"?>
	<section id="container">
		<div class="form_register">
			<h1>Actualizar Proveedor</h1>
			<hr>
			<div class="alert"><?php echo isset($alert) ?$alert : ''; ?></div>
			<form action="" method="post">
				<?php // <?php echo $idproveedor  sirve para mostrar los datos que extaemos de la consulta ?>
				<input type="hidden" name="id" value="<?php echo $idproveedor ?>">
				<label for="proveedor">Proveedor</label>
				<input type="text" name="proveedor" id="proveedor" placeholder="Nombre del proveedor" value="<?php echo $proveedor ?>">
				<label for="contacto">Contacto</label>
				<input type="text" name="contacto" id="contacto" placeholder="nombre completo del contacto" value="<?php echo $contacto ?>">
				<label for="telefono">Telefono</label>
				<input type="number" name="telefono" id="telefono" placeholder="Telefono" value="<?php echo $telefono ?>">
				<label for="direccion">Direccion</label>
				<input type="text" name="direccion" id="direccion" placeholder="Direccion" value="<?php echo $direccion ?>">
				<button type="submit" class="btn_save"><i class="far fa-edit fa-lg"></i> Actualizar Proveedor</button>
			</form>
		</div>
		
	</section>
	<?php include "includes/footer.php"?>
</body>
</html>