<?php

session_start();
//si es diefernte de 1 o 2 visualize el menu
if($_SESSION['rol']!= 1 and $_SESSION['rol']!= 2)
{
	header("location: ./");
} 
include "../conexion.php";
?>


<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<?php include "includes/scripts.php"?>
	<title>Lista Proveedor</title>
</head>
<body>
	<?php include "includes/header.php"?>
	<section id="container">

		<?php
			$busqueda = $_REQUEST['busqueda'];
			if(empty($busqueda)){
				header("location: lista_proveedor.php");
				mysqli_close($conection);
			}

		?>
		<h1><i class="far fa-building"></i> Lista de Proveedor</h1>
		<a href="registro_proveedor.php" class="btn_new"> <i class="fas fa-plus"></i> Crear Proveedor</a>
		
		<form action="buscar_proveedor.php" method="get" class="form_search">
			<input type="text" name="busqueda" id="busqueda" placeholder="Buscar" value="<?php echo $busqueda;?>">
			<input type="submit" value="Buscar" class="btn_search">
		</form>
	
		<table>
			<tr>
				<th>ID</th>
				<th>Proveedor</th>
				<th>Contacto</th>
				<th>Telefono</th>
				<th>Direcion</th>
				<th>Fecha</th>
				<th>Acciones</th>
			</tr>

			<?php

			//paginador
			

			$sql_registe = mysqli_query($conection, "SELECT count(*) as total_registro from proveedor 
													where ( codproveedor like '%$busqueda%' or 
															proveedor like '%$busqueda%' or
															contacto like '%$busqueda%' or
															telefono like '%$busqueda%')
															and	estatus = 1 ");
			
			$result_regsiter = mysqli_fetch_array($sql_registe);
			
			$total_registro = $result_regsiter['total_registro'];


			$por_pagina = 2;

			if(empty($_GET['pagina']))
			{
				$pagina = 1;

			}else{
				$pagina = $_GET['pagina'];
			}

			$desde = ($pagina - 1 ) * $por_pagina;
			$total_pagina = ceil($total_registro / $por_pagina);


				$query = mysqli_query($conection,"SELECT * FROM proveedor
												 WHERE (
														codproveedor like '%$busqueda%' or 
														proveedor like '%$busqueda%' or
														contacto like '%$busqueda%' or
														telefono like '%$busqueda%')
													AND
													estatus= 1 order by codproveedor
													limit $desde,$por_pagina");
				mysqli_close($conection);
				$result = mysqli_num_rows($query);

				if($result >0){
					while($data=mysqli_fetch_array($query)){

						$formato = 'Y-m-d H:i:s';
						$fecha = DateTime::createFromFormat($formato, $data["date_add"]);

			?>
			<tr>
				<td><?php echo $data["codproveedor"]?></td>
				<td><?php echo $data["proveedor"]?></td>
				<td><?php echo $data["contacto"]?></td>
				<td><?php echo $data["telefono"]?></td>
				<td><?php echo $data["direccion"]?></td>
				<td><?php echo $fecha->format('d-m-Y'); ?></td>
				<td>
					<a class="link_edit" href="editar_proveedor.php?id=<?php echo $data["codproveedor"]?>">Editar</a>
					|
					<a class="link_delete"href="eliminar_confirmar_proveedor.php?id=<?php echo $data["codproveedor"]?>">Eliminar</a>
			
					
				</td>
			</tr>
			<?php
					}
				}
			?>
			
			
			

		</table>

		<?php
		if($total_registro != 0)
		{


		?>
		<div class="paginador">
			<ul>
				<?php
					if($pagina != 1){


				?>
				<li><a href="?pagina=<?php echo 1;?>&busqueda=<?php echo $busqueda;?>">|<</a></li>
				<li><a href="?pagina=<?php echo $pagina-1;?>"><<</a></li>
				<?php
				}
					for ($i=1; $i <= $total_pagina; $i++)
						{
							if($i == $pagina)
							{
								echo '<li class="pagesSelected">'.$i.'</li>';
							}else{
								echo '<li><a href="?pagina='.$i.'$busqueda='.$busqueda.'">'.$i.'</a></li>';
							
							}
						}
						if($pagina != $total_pagina)
						{
					?>
				<li><a href="?pagina=<?php echo $pagina+1;?>&busqueda=<?php echo $busqueda;?>">>></a></li>
				<li><a href="?pagina=<?php echo $total_pagina;?>&busqueda=<?php echo $busqueda;?>">>|</a></li>
						<?php 
						}
						?>				
			</ul>
		</div>
	<?php } ?>
	</section>
	<?php include "includes/footer.php"?>
</body>
</html>







