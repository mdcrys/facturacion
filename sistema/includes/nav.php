<nav>
			<ul>
				<li><a href="index.php"><i class="fas fa-home"></i> Inicio</a></li>
				<?php
					if($_SESSION['rol'] ==1 )
					{
						
				?>	
				<li class="principal">
					
					<a href="lista_usuarios.php"><i class="fas fa-users"></i> Usuarios</a>
					<ul>
						<li><a href="registro_usuario.php"><i class="fas fa-user"></i> Nuevo Usuario</a></li>
						<li><a href="lista_usuarios.php"><i class="fas fa-users"></i> Lista de Usuarios</a></li>
					</ul>
				</li>
				<?php
				} 
				?>
				<li class="principal">
					<a href="#">Clientes</a>
					<ul>
						<li><a href="registro_cliente.php">Nuevo Cliente</a></li>
						<li><a href="lista_clientes.php">Lista de Clientes</a></li>
					</ul>
				</li>
				<?php
					if($_SESSION['rol'] ==1  || $_SESSION['rol'] ==2)
					{
						
				?>	
				<li class="principal">
					<a href="#">Proveedores</a>
					<ul>
						<li><a href="registro_proveedor.php">Nuevo Proveedor</a></li>
						<li><a href="lista_proveedor.php">Lista de Proveedores</a></li>
					</ul>
				</li>
				<?php
				} 
				?>
			
			</ul>
		</nav>