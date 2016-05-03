<form method="POST" action="<?php $this ?>">
	<dl>
		<dt><label for="pCode">Product Code</label></dt>
		<dt><input type="text" name="pCode" value="<?php $_POST["pCode"]?>" id="pCode" /></dt>
		<dt><label for="name">Name</label></dt>	
		<dt><input type="text" name="name" value="<?php $_POST["name"]?>" id="name" /></dt>
		<dt><label for="email">e-Mail</label></dt>	
		<dt><input type="text" name="email" value="<?php $_POST["email"]?>" id="email" /></dt>
		<dt><input type="submit"/></dt>
	</dl>
</form>

<?php
	if ($_POST["pCode"] && $_POST["name"] && $_POST["email"]){
	
		include_once('license_generator.php');
		$lic = new License_Generator;
		$code = $lic->make_license($_POST["pCode"], $_POST["name"], $_POST["email"]);
		echo 'Your License:<br><strong>' . $code ."</strong>";
	}
?>

