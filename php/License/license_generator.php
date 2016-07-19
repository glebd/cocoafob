<?php
include('base32.php');
class License_Generator
{
	private $private_key;
	private $public_key;

	#-#############################################
	# desc: constructor
	function License_Generator(){


		## NOTE ###############################################
		# Point the key loading functions to your private and public keys on your server.

		//read the Private Key from disk
		$this->private_key = file_get_contents('./dsa_priv.pem', FILE_USE_INCLUDE_PATH);
		//read the public Key from disk
		$this->public_key = file_get_contents('./dsa_pub.pem', FILE_USE_INCLUDE_PATH);
	}#-#constructor()

	#-#############################################
	# desc: Create a license
	public function make_license($product_code, $name, $email)
	{
		## NOTE ###############################################
		# If you change the parameters the function acepts do not 
		# forget to change the lower string concatenation
		# to include all fields in the license generation

		$stringData = $product_code.",".$name.",".$email;

		#################################################
		$binary_signature ="";
		openssl_sign($stringData, $binary_signature, $this->private_key, OPENSSL_ALGO_DSS1);
		// base 32 encode the signature
		$encoded = base32_encode($binary_signature);
		// replace O with 8 and I with 9
		$replacement = str_replace("O", "8", str_replace("I", "9", $encoded));
		//remove padding if any.
		$padding = trim(str_replace("=", "", $replacement));
		$dashed = rtrim(chunk_split($padding, 5,"-"));
		$theKey = substr($dashed, 0 , strlen($dashed) -1);

		return $theKey;
	}

	#-#############################################
	# desc: Verify License
	public function verify_license($product_code, $name, $email, $license)
	{
		## NOTE ###############################################
		# If you change the parameters the function acepts do not 
		# forget to change the lower string concatenation
		# to include all fields in the license generation
		
		$stringData = $product_code.",".$name.",".$email;
		
		#################################################		
		// replace O with 8 and I with 9
		$replacement = str_replace("8", "O", str_replace("9", "I", $license));
		//remove Dashes.
		$undashed = trim(str_replace("-", "", $replacement));
		// Pad the output length to a multiple of 8 with '=' characters
		$desiredLength = strlen($undashed);
		if($desiredLength % 8 != 0) {
			$desiredLength += (8 - ($desiredLength % 8));
			$undashed = str_pad($undashed, $desiredLength, "=");
		}
		// decode Key
		$decodedHash = base32_decode($undashed);

		$ok = openssl_verify($stringData, $decodedHash, $this->public_key, OPENSSL_ALGO_DSS1);
		if ($ok == 1) {
		    return TRUE;
		} elseif ($ok == 0) {
		    return FALSE;
		} else {
		    return FALSE;
		}
	}

} # Class License
?>