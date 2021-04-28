<?php
	session_start();

	include "../conexion.php";
?>


<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<?php include "includes/scripts.php"?>
	<title>Lista Productos</title>
</head>
<body>
	<?php include "includes/header.php"?>
	<section id="container">
		<h1>Lista de productos</h1>
		<a href="registro_producto.php" class="btn_new">Crear Producto</a>
		
		<form action="buscar_producto.php" method="get" class="form_search">
			<input type="text" name="busqueda" id="busqueda" placeholder="Buscar">
			<input type="submit" value="Buscar" class="btn_search">
		</form>
	
		<table>
			<tr>
				<th>Còdigo</th>
				<th>Descripcion</th>
				<th>Precio</th>
				<th>Existencias</th>
				<th>
					<?php 
					$query_proveedor = mysqli_query($conection, "SELECT codproveedor, proveedor FROM proveedor WHERE estatus = 1 order by proveedor ASC");
					$result_proveedor = mysqli_num_rows($query_proveedor);

				?>
				<select name="proveedor" id="search_proveedor">
					<option value="" selected>PROVEEDOR</option>
					<?php
						if($result_proveedor > 0)
						{
							while ($proveedor = mysqli_fetch_array($query_proveedor)) {
					?>
					<option value="<?php echo $proveedor['codproveedor'];?>"><?php echo $proveedor['proveedor'];?> </option>
					<?php
							}
						}
					?>
					
				</select>


				</th>
				<th>Foto</th>
				<th>Acciones</th>
			</tr>

			<?php

			//paginador

			$sql_registe = mysqli_query($conection, "SELECT count(*) as total_registro from producto where estatus = 1");
			$result_regsiter = mysqli_fetch_array($sql_registe);
			$total_registro = $result_regsiter['total_registro'];


			$por_pagina = 7;

			if(empty($_GET['pagina']))
			{
				$pagina = 1;

			}else{
				$pagina = $_GET['pagina'];
			}

			$desde = ($pagina - 1 ) * $por_pagina;
			$total_pagina = ceil($total_registro / $por_pagina);


				$query = mysqli_query($conection,"SELECT p.codproducto, p.descripcion, p.precio, p.existencia, pr.proveedor, p.foto  FROM producto p INNER JOIN proveedor pr ON p.proveedor = pr.codproveedor
														   WHERE p.estatus= 1 order by p.codproducto desc LIMIT $desde,$por_pagina");
				mysqli_close($conection);

				$result = mysqli_num_rows($query);

				if($result >0){

					while($data=mysqli_fetch_array($query)){

						 if ($data['foto'] != 'img_producto.png'){
						 	$foto = 'img/uploads/'.$data['foto'];
						 }else{
						 	$foto = 'img/'.$data['foto'];
						 }
			?>
			<tr class="row<?php echo $data["codproducto"]?>">
				<td><?php echo $data["codproducto"]?></td>
				<td><?php echo $data["descripcion"]?></td>
				<td class="celPrecio"><?php echo $data["precio"]?></td>
				<td class="celExistencia"><?php echo $data["existencia"]?></td>
				<td><?php echo $data["proveedor"]?></td>
				<td class="img_producto"><img src="<?php echo $foto; ?>" alt=""></td>
				<?php if($_SESSION['rol'] == 1 || $_SESSION['rol'] == 2){?>
				<td>
					<a class="link_add add_product" product="<?php echo $data["codproducto"]; ?>" href="#">Agregar</a>
					|
					<a class="link_edit" href="editar_producto.php?id=<?php echo $data["codproducto"]?>">Editar</a>
					|
					<a class="link_delete del_product" href="#" product="<?php echo $data["codproducto"]; ?>"><i class="far fa-trash-alt"></i>Eliminar</a>
			
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







