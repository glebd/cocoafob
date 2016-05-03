<?php
include('base32.php');

	$lic = new License_Generator;
	$code = $lic->make_license('GESTOBM30', 'Sandro Noel', 'sandro.noel@gesosoft.com');

// to verify a Key from cocoafob place it in here.


echo "<br><br><strong>Verify the cocoafob License<br></strong>";				
?>
<form method="post" action="Generate.php">
	<dl>
		<dt><label for="key">cocoafob License</label></dt>
		<dt><input type="text" name="key" value="" id="key" /></dd>
		<dd><input type="submit"/></dd>
	</dl>
</form>
<?php
	if ($_POST["key"]){
		$key = $_POST["key"];
		$result = $lic->verify_license('GESTOBM30', 'Sandro Noel', 'sandro.noel@gesosoft.com',$key);
	}
?>

<?php


class License_Generator
{

	private $private_key;
	private $public_key;

	#-#############################################
	# desc: constructor
	function License_Generator(){
		//NOTE : should read thm from the database instead.
		//read the Private Key from disk
		$this->private_key = file_get_contents('./dsa_priv.pem', FILE_USE_INCLUDE_PATH);
		//read the public Key from disk
		$this->public_key = file_get_contents('./dsa_pub.pem', FILE_USE_INCLUDE_PATH);
	}#-#constructor()

	#-#############################################
	# desc: Create a license
	public function make_license($product_code, $name, $email)
	{
		// Generae a sha1 digest with the passed parameters.
		$stringData = $product_code.",".$name.",".$email;
	echo "Data: ".$stringData."<br>";
		$binary_signature ="";
		openssl_sign($stringData, $binary_signature, $this->private_key, OPENSSL_ALGO_DSS1);
	echo "Binary Sig: ".$binary_signature."<br>";
		
		// base 32 encode the stuff
		$encoded = base32_encode($binary_signature);
	echo "Original Key: ". $encoded ."<br>";
	echo "Key Length: ". strlen($encoded) ."<br>";
		
		// replace O with 8 and I with 9
		$replacement = str_replace("O", "8", str_replace("I", "9", $encoded));
	echo "Replaced: " .$replacement . "<br>";

		//remove padding if any.
		$padding = trim(str_replace("=", "", $replacement));
	echo "Stripped: " .$padding . "<br>";		
		
		
		$dashed = rtrim(chunk_split($padding, 5,"-"));
		$theKey = substr($dashed, 0 , strlen($dashed) -1);
	echo "Dashed: " .$theKey . "<br><br>";				
		


	echo "<strong>Verify the just created License<br></strong>";				

		$this->verify_license($product_code, $name, $email, $theKey);
		
		return $theKey;
	}

	#-#############################################
	# desc: Verify License
	public function verify_license($product_code, $name, $email, $lic)
	{
	echo "Original: <strong>" .$lic . "</strong><br>";	
		// replace O with 8 and I with 9
		$replacement = str_replace("8", "O", str_replace("9", "I", $lic));
	echo "Replaced: " .$replacement . "<br>";	
		//remove Dashes.
		$undashed = trim(str_replace("-", "", $replacement));
	echo "Undashed: " .$undashed . "<br>";		
	echo "Key Length: ". strlen($undashed) ."<br>";
	// Pad the output length to a multiple of 8 with '=' characters
	$desiredLength = strlen($undashed);
	if($desiredLength % 8 != 0) {
		$desiredLength += (8 - ($desiredLength % 8));
		$undashed = str_pad($undashed, $desiredLength, "=");
	}
	echo "padded: " .$undashed . "<br>";		
		// decode Key
		$decodedHash = base32_decode($undashed);
	echo "Binary Sig: ".$decodedHash. "<br>";				
		//digest the original Data
		$stringData = $product_code.",".$name.",".$email;
		$ok = openssl_verify($stringData, $decodedHash, $this->public_key, OPENSSL_ALGO_DSS1);
		if ($ok == 1) {
		    echo "<strong>GOOD</strong>";
		} elseif ($ok == 0) {
		    echo "<strong>BAD</strong>";
		} else {
		    echo "<strong>ugly, error checking signature</strong>";
		}
	}

} # Class License
?>