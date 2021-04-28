<?php
	session_start();

	include "../conexion.php";
?>


<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<?php include "includes/scripts.php"?>
	<title>Lista Clientes</title>
</head>
<body>
	<?php include "includes/header.php"?>
	<section id="container">
		<h1>Lista de clientes</h1>
		<a href="registro_cliente.php" class="btn_new">Crear cliente</a>
		
		<form action="buscar_cliente.php" method="get" class="form_search">
			<input type="text" name="busqueda" id="busqueda" placeholder="Buscar">
			<input type="submit" value="Buscar" class="btn_search">
		</form>
	
		<table>
			<tr>
				<th>ID</th>
				<th>NIT</th>
				<th>Nombre</th>
				<th>Telefono</th>
				<th>Direcion</th>
				<th>Acciones</th>
			</tr>

			<?php

			//paginador

			$sql_registe = mysqli_query($conection, "SELECT count(*) as total_registro from cliente where estatus = 1");
			$result_regsiter = mysqli_fetch_array($sql_registe);
			$total_registro = $result_regsiter['total_registro'];


			$por_pagina = 3;

			if(empty($_GET['pagina']))
			{
				$pagina = 1;

			}else{
				$pagina = $_GET['pagina'];
			}

			$desde = ($pagina - 1 ) * $por_pagina;
			$total_pagina = ceil($total_registro / $por_pagina);


				$query = mysqli_query($conection,"SELECT * FROM cliente
														   WHERE estatus= 1 order by idcliente ASC LIMIT $desde,$por_pagina");
				mysqli_close($conection);

				$result = mysqli_num_rows($query);

				if($result >0){

					while($data=mysqli_fetch_array($query)){

						if($data["nit"] == 0){
							$nit = 'C/F';
						}else{
							$nit=$data["nit"];
						}
			?>
			<tr>
				<td><?php echo $data["idcliente"]?></td>
				<td><?php echo $data["nit"]?></td>
				<td><?php echo $data["nombre"]?></td>
				<td><?php echo $data["telefono"]?></td>
				<td><?php echo $data["direccion"]?></td>
				
				<td>
					<a class="link_edit" href="editar_cliente.php?id=<?php echo $data["idcliente"]?>">Editar</a>
					<?php if($_SESSION['rol'] == 1 || $_SESSION['rol'] == 2){?>
					|
					<a class="link_delete"href="eliminar_confirmar_cliente.php?id=<?php echo $data["idcliente"]?>">Eliminar</a>
			
					<?php } ?>
				</td>
			</tr>
			<?php
					}
				}
			?>
			
			
			

		</table>
		<div class="paginador">
			<ul>
				<?php
					if($pagina != 1){


				?>
				<li><a href="?pagina=<?php echo 1;?>">|<</a></li>
				<li><a href="?pagina=<?php echo $pagina-1;?>"><<</a></li>
				<?php
				}
					for ($i=1; $i <= $total_pagina; $i++)
						{
							if($i == $pagina)
							{
								echo '<li class="pagesSelected">'.$i.'</li>';
							}else{
								echo '<li><a href="?pagina='.$i.'">'.$i.'</a></li>';
							
							}
						}
						if($pagina != $total_pagina)
						{
					?>
				<li><a href="?pagina=<?php echo $pagina+1;?>">>></a></li>
				<li><a href="?pagina=<?php echo $total_pagina;?>">>|</a></li>
						<?php 
						}
						?>				
			</ul>
		</div>
	</section>
	<?php include "includes/footer.php"?>
</body>
</html>







