<form method="post" action="<?php $this ?>">
	<dl>
		<dt><label for="pCode">Product Code</label></dt>
		<dt><input type="text" name="pCode" value="<?php $_POST["pCode"]?>" id="pCode" /></dt>
		<dt><label for="name">Name</label></dt>	
		<dt><input type="text" name="name" value="<?php $_POST["name"]?>" id="name" /></dt>
		<dt><label for="email">e-Mail</label></dt>	
		<dt><input type="text" name="email" value="<?php $_POST["email"]?>" id="email" /></dt>
		<dt><label for="key">Enter License Key</label></dt>
		<dt><input type="text" name="key" value="" id="key" /></dd>
		<dt><input type="submit"/></dd>
	</dl>
</form>

<?php
	include_once('license_generator.php');
	if ($_POST["key"] && $_POST["pCode"] && $_POST["name"] && $_POST["email"]){
		$lic = new License_Generator;
		$result = $lic->verify_license($_POST["pCode"], $_POST["name"], $_POST["email"],$_POST["key"]);
		if ($result)
			echo "Valid";
		else
			echo "Invalid";		
	}
?>
