<?php
session_start();

include "../conexion.php";

$busqueda = "";
$fecha_de = "";
$fecha_a = "";

if(isset($_REQUEST['busqueda'])&& $_REQUEST['busqueda'] == '')
{
	header("location:ventas.php");
}
if (isset($_REQUEST['fecha_de']) || isset($_REQUEST['fecha_a']))
{
	if ($_REQUEST['fecha_de'] == '' || $_REQUEST['fecha_a'] == '') {
		header("location:ventas.php");
	}
}

if(!empty($_REQUEST['busqueda'])){
	if(!is_numeric($_REQUEST['busqueda'])){
		header("location:ventas.php");
	}
	$busqueda = strtolower($_REQUEST['busqueda']);
	$where = "nofactura = $busqueda";
	$buscar = "busqueda = $busqueda";
}

if(!empty($_REQUEST['fecha_de']) && !empty($_REQUEST['fecha_a'])){
	$fecha_de = $_REQUEST['fecha_de'];
	$fecha_a = $_REQUEST['fecha_a'];

	$buscar = '';

	if($fecha_de > $fecha_a){
		header("location:ventas.php");
	}elseif ($fecha_de == $fecha_a) {
		$where = "fecha LIKE '$fecha_de%'";
		$buscar = "fecha_de=fecha_de&fecha_a=fecha_a";
	}else{
		$f_de = $fecha_de.'00:00:00';
		$f_a = $fecha_a.'23:59:59';
		$where = "fecha BETWEEN '$f_de' AND '$f_a'";
		$buscar = "fecha_de=$fecha_de&fecha_a=$fecha_a";

	}
}


?>


<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<?php include "includes/scripts.php"?>
	<title>Lista de ventas</title>
</head>
<body>
	<?php include "includes/header.php"?>
	<section id="container">
		<h1><i class="far fa-newspaper"></i>Lista de Ventas</h1>
		<a href="nueva_venta.php" class="btn_new">Nueva Venta</a>
		
		<form action="buscar_venta.php" method="get" class="form_search">
			<input type="text" name="busqueda" id="busqueda" placeholder="No. Factura" value="<?php echo $busqueda; ?>">
			<input type="submit" value="Buscar" class="btn_search">
		</form>

		<div>
			<h5>Bucar por Fechas</h5>
				<form action="buscar_venta.php" method="get" class="form_search_date">
					<label>De:</label>
					<input type="date" name="fecha_de" id="fecha_de" value="<?php echo $fecha_a ?>" required>
					<label>A:</label>
					<input type="date" name="fecha_a" id="fecha_a" value="<?php echo $fecha_a; ?>"required>
					<button type="submit" class="btn_view"><i class="fas fa-search"></i></button>
				</form>
			
		</div>
		<table>
			<tr>
				<th>No.</th>
				<th>fecha / Hora</th>
				<th>Cliente</th>
				<th>Vendedor</th>
				<th>Estado</th>
				<th class="textright">Total Factura</th>
				<th class="textright">Acciones</th>
			</tr>

			<?php

			//paginador

			$sql_registe = mysqli_query($conection, "SELECT count(*) as total_registro from factura where $where");
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


			$query = mysqli_query($conection,"SELECT f.nofactura,f.fecha,f.totalfactura,f.codcliente,											f.estatus, u.nombre as vendedor, cl.nombre as cliente 										FROM factura f
											INNER JOIN usuario u
											ON f.usuario = u.idusuario
											INNER JOIN cliente cl
											ON f.codcliente = cl.idcliente
											WHERE $where AND f.estatus != 10
											order by f.fecha DESC LIMIT $desde,$por_pagina");
			mysqli_close($conection);

			$result = mysqli_num_rows($query);
				//print_r($query);exit;
			if($result >0){

				while($data=mysqli_fetch_array($query)){
					if ($data["estatus"] == 1) {
						$estado = '<span class="pagada">Pagada</span>';
							# code...
					}else{
						$estado = '<span class="anulada">Anulada</span>';
					}

					?>
					<tr id="row_ <?php echo $data['nofactura'];  ?>">
						<td><?php echo $data["nofactura"]?></td>
						<td><?php echo $data["fecha"]?></td>
						<td><?php echo $data["cliente"]?></td>
						<td><?php echo $data["vendedor"]?></td>
						<td class="estado"><?php echo $estado;?></td> 
						<td class="textright totalfactura"><span>Q.</span><?php echo $data["totalfactura"];?></td>

						<td>
							<div class="div_acciones">
								<div>
									<button class="btn_view view_factura" type="button" cl="<?php echo $data['codcliente'] ?>" f="<?php echo $data['nofactura'] ?>"><i class="fas fa-eye"></i></button>
								</div>

								<?php if($_SESSION['rol'] == 1 || $_SESSION['rol'] == 2){
									if($data['estatus'] == 1)
									{
										?>
										<div class="div_factura">
											<button class="btn_anular anular_factura" fac="<?php echo $data['nofactura'] ?>"><i class="fas fa-ban"></i></button>
										</div>

									<?php }else{  ?>
										<div class="div_factura">
											<button class="btn_anular inactive"><i class="fas fa-ban"></i></button>
										</div>
									<?php }
								} ?>
							</div>
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
					<li><a href="?pagina=<?php echo 1;?>&<?php echo $buscar; ?>"><i class="fas fa-step-backward"></i></a></li>
					<li><a href="?pagina=<?php echo $pagina-1;?>&<?php echo $buscar; ?>"><i class="fas fa-backward"></i></a></li>
					<?php
				}
				for ($i=1; $i <= $total_pagina; $i++)
				{
					if($i == $pagina)
					{
						echo '<li class="pagesSelected">'.$i.'</li>';
					}else{
						echo '<li><a href="?pagina='.$i.'&'.$buscar.'">'.$i.'</a></li>';

					}
				}
				if($pagina != $total_pagina)
				{
					?>
					<li><a href="?pagina=<?php echo $pagina+1;?>&<?php echo $buscar; ?>"><i class="fas fa-forwad"></i></a></li>
					<li><a href="?pagina=<?php echo $total_pagina;?>&<?php echo $buscar; ?>"><i class="fas fa-step-forwad"></i></a></li>
					<?php 
				}
				?>				
			</ul>
		</div>
	</section>
	<?php include "includes/footer.php"?>
</body>
</html>
