<?php
function base32_encode($input) {
	// Get a binary representation of $input
	$binary = unpack('C*', $input);
	$binary = vsprintf(str_repeat('%08b', count($binary)), $binary);
 
	$binaryLength = strlen($binary);
	$base32_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";	
	$currentPosition = 0;
	$output = '';
 
	while($currentPosition < $binaryLength) {
		$bits = substr($binary, $currentPosition, 5);
 
		if(strlen($bits) < 5)
			$bits = str_pad($bits, 5, "0");
 
		// Convert the 5 bits into a decimal number
		// and append the matching character to $output
		$output .= $base32_characters[bindec($bits)];
		$currentPosition += 5;
	}
 	// Pad the output length to a multiple of 8 with '=' characters
	$desiredOutputLength = strlen($output);
	if($desiredOutputLength % 8 != 0) {
		$desiredOutputLength += (8 - ($desiredOutputLength % 8));
		$output = str_pad($output, $desiredOutputLength, "=");
	}
 	return $output;
}




function Base32_decode($inStr) {

	$inString = strtolower(rtrim(str_replace("=", "", $inStr)));
    /* declaration */
    $inputCheck = null;
    $deCompBits = null;
    
    $BASE32_TABLE = array( 
                          0x61 => '00000', 
                          0x62 => '00001', 
                          0x63 => '00010', 
                          0x64 => '00011', 
                          0x65 => '00100', 
                          0x66 => '00101', 
                          0x67 => '00110', 
                          0x68 => '00111', 
                          0x69 => '01000', 
                          0x6a => '01001', 
                          0x6b => '01010', 
                          0x6c => '01011', 
                          0x6d => '01100', 
                          0x6e => '01101', 
                          0x6f => '01110', 
                          0x70 => '01111', 
                          0x71 => '10000', 
                          0x72 => '10001', 
                          0x73 => '10010', 
                          0x74 => '10011', 
                          0x75 => '10100', 
                          0x76 => '10101', 
                          0x77 => '10110', 
                          0x78 => '10111', 
                          0x79 => '11000', 
                          0x7a => '11001', 
                          0x32 => '11010', 
                          0x33 => '11011', 
                          0x34 => '11100', 
                          0x35 => '11101', 
                          0x36 => '11110', 
                          0x37 => '11111', 
                          ); 
    
    /* Step 1 */
    $inputCheck = strlen($inString) % 8;
    if(($inputCheck == 1)||($inputCheck == 3)||($inputCheck == 6)) { 
        trigger_error('input to Base32Decode was a bad mod length: '.$inputCheck);
        return false; 
        //return $this->raiseError('input to Base32Decode was a bad mod length: '.$inputCheck, null, 
        // PEAR_ERROR_DIE, null, null, 'Net_RACE_Error', false );
    }
    
    /* $deCompBits is a string that represents the bits as 0 and 1.*/
    for ($i = 0; $i < strlen($inString); $i++) {
        $inChar = ord(substr($inString,$i,1));
        if(isset($BASE32_TABLE[$inChar])) {
            $deCompBits .= $BASE32_TABLE[$inChar];
        } else {
            trigger_error('input to Base32Decode had a bad character: '.$inChar.":".substr($inString,$i,1));
            return false;
            //return $this->raiseError('input to Base32Decode had a bad character: '.$inChar, null, 
            //    PEAR_ERROR_DIE, null, null, 'Net_RACE_Error', false );
        }
    }
    
    /* Step 5 */
    $padding = strlen($deCompBits) % 8;
    $paddingContent = substr($deCompBits, (strlen($deCompBits) - $padding));
    if(substr_count($paddingContent, '1')>0) { 
        trigger_error('found non-zero padding in Base32Decode');
        return false;
        //return $this->raiseError('found non-zero padding in Base32Decode', null, 
        //    PEAR_ERROR_DIE, null, null, 'Net_RACE_Error', false );
    }
    
    /* Break the decompressed string into octets for returning */
    $deArr = array();
    for($i = 0; $i < (int)(strlen($deCompBits) / 8); $i++) {
        $deArr[$i] = chr(bindec(substr($deCompBits, $i*8, 8)));
    }
    
    $outString = join('',$deArr);
    
    return $outString;
}

?>