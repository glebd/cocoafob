package com.xk72.cocoafob;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.security.InvalidKeyException;
import java.security.KeyPair;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SecureRandom;
import java.security.Security;
import java.security.Signature;
import java.security.SignatureException;
import java.security.interfaces.DSAPrivateKey;
import java.security.interfaces.DSAPublicKey;

import org.apache.commons.codec.binary.Base32;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.openssl.PEMReader;

/**
 * Generate and verify CocoaFob licenses. Based on the PHP implementation by Sandro Noel.
 * @author karlvr
 *
 */
public class LicenseGenerator {
	
	private DSAPrivateKey privateKey;
	private DSAPublicKey publicKey;
	private SecureRandom random;
	
	static {
		Security.addProvider(new BouncyCastleProvider());
	}
	
	protected LicenseGenerator() {
		random = new SecureRandom();
	}
	
	/**
	 * Construct the LicenseGenerator with a URL that points to either the private key or public key.
	 * Pass the private key for making and verifying licenses. Pass the public key for verifying only.
	 * If you this code will go onto a user's machine you MUST NOT include the private key, only include
	 * the public key in this case. 
	 * @param keyURL
	 * @throws IOException
	 */
	public LicenseGenerator(URL keyURL) throws IOException {
		this();
		initKeys(keyURL.openStream());
	}
	
	/**
	 * Construct the LicenseGenerator with an InputStream of either the private key or public key.
	 * Pass the private key for making and verifying licenses. Pass the public key for verifying only.
	 * If you this code will go onto a user's machine you MUST NOT include the private key, only include
	 * the public key in this case. 
	 * @param keyURL
	 * @throws IOException
	 */
	public LicenseGenerator(InputStream keyInputStream) throws IOException {
		this();
		initKeys(keyInputStream);
	}
	
	private void initKeys(InputStream keyInputStream) throws IOException {
		Object readKey = readKey(keyInputStream);
		if (readKey instanceof KeyPair) {
			KeyPair keyPair = (KeyPair) readKey;
			privateKey = (DSAPrivateKey) keyPair.getPrivate();
			publicKey = (DSAPublicKey) keyPair.getPublic();
		} else if (readKey instanceof DSAPublicKey) {
			publicKey = (DSAPublicKey) readKey;
		} else {
			throw new IllegalArgumentException("The supplied key stream didn't contain a public or private key: " + readKey.getClass());
		}
	}

	private Object readKey(InputStream privateKeyInputSteam) throws IOException {
		PEMReader pemReader = new PEMReader(new InputStreamReader(new BufferedInputStream(privateKeyInputSteam)));
		try {
			return pemReader.readObject();
		} finally {
			pemReader.close();
		}
	}

	/**
	 * Make and return a license for the given {@link LicenseData}.
	 * @param licenseData
	 * @return
	 * @throws LicenseGeneratorException If the generation encounters an error, usually due to invalid input.
	 * @throws IllegalStateException If the generator is not setup correctly to make licenses.
	 */
	public String makeLicense(LicenseData licenseData) throws LicenseGeneratorException, IllegalStateException {
		if (!isCanMakeLicenses()) {
			throw new IllegalStateException("The LicenseGenerator cannot make licenses as it was not configured with a private key");
		}
		
		final String stringData = licenseData.toLicenseStringData();
		
		try {
			final Signature dsa = Signature.getInstance("SHA1withDSA", "SUN");
			dsa.initSign(privateKey, random);
			dsa.update(stringData.getBytes("UTF-8"));
			
			final byte[] signed = dsa.sign();
			
			/* base 32 encode the signature */
			String result = new Base32().encodeAsString(signed);
			
			/* replace O with 8 and I with 9 */
			result = result.replace("O", "8").replace("I",  "9");
			
			/* remove padding if any. */
			result = result.replace("=", "");
			
			/* chunk with dashes */
			result = split(result, 5);
			return result;
		} catch (NoSuchAlgorithmException e) {
			throw new LicenseGeneratorException(e);
		} catch (NoSuchProviderException e) {
			throw new LicenseGeneratorException(e);
		} catch (InvalidKeyException e) {
			throw new LicenseGeneratorException(e);
		} catch (SignatureException e) {
			throw new LicenseGeneratorException(e);
		} catch (UnsupportedEncodingException e) {
			throw new LicenseGeneratorException(e);
		}
	}

	/**
	 * Verify the given license for the given {@link LicenseData}.
	 * @param licenseData
	 * @param license
	 * @return Whether the license verified successfully.
	 * @throws LicenseGeneratorException If the verification encounters an error, usually due to invalid input. You MUST check the return value of this method if no exception is thrown.
	 * @throws IllegalStateException If the generator is not setup correctly to verify licenses.
	 */
	public boolean verifyLicense(LicenseData licenseData, String license) throws LicenseGeneratorException, IllegalStateException {
		if (!isCanVerifyLicenses()) {
			throw new IllegalStateException("The LicenseGenerator cannot verify licenses as it was not configured with a public key");
		}
		
		final String stringData = licenseData.toLicenseStringData();
		
		/* replace O with 8 and I with 9 */
		String licenseSignature = license.replace("8", "O").replace("9", "I");
		
		/* remove dashes */
		licenseSignature = licenseSignature.replace("-", "");
		
		/* Pad the output length to a multiple of 8 with '=' characters */
		while (licenseSignature.length() % 8 != 0) {
			licenseSignature += "=";
		}
		
		byte[] decoded = new Base32().decode(licenseSignature);
		try {
			Signature dsa = Signature.getInstance("SHA1withDSA", "SUN");
			dsa.initVerify(publicKey);
			dsa.update(stringData.getBytes("UTF-8"));
			return dsa.verify(decoded);
		} catch (NoSuchAlgorithmException e) {
			throw new LicenseGeneratorException(e);
		} catch (NoSuchProviderException e) {
			throw new LicenseGeneratorException(e);
		} catch (InvalidKeyException e) {
			throw new LicenseGeneratorException(e);
		} catch (SignatureException e) {
			throw new LicenseGeneratorException(e);
		} catch (UnsupportedEncodingException e) {
			throw new LicenseGeneratorException(e);
		}
	}

	private String split(String str, int chunkSize) {
		StringBuilder result = new StringBuilder();
		int i = 0;
		while (i < str.length()) {
			if (i > 0) {
				result.append('-');
			}
			int next = Math.min(i + chunkSize, str.length());
			result.append(str.substring(i, next));
			i = next;
		}
		return result.toString();
	}
	
	public boolean isCanMakeLicenses() {
		return privateKey != null;
	}
	
	public boolean isCanVerifyLicenses() {
		return publicKey != null;
	}
	
}
