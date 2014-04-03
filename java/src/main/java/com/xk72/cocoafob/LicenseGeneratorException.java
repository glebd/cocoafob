package com.xk72.cocoafob;

/**
 * An error occurred in the license generation or verification. This generally means that the input
 * was malformed somehow and should be rejected.
 * @author karlvr
 *
 */
public class LicenseGeneratorException extends Exception {

	public LicenseGeneratorException() {
		super();
	}

	public LicenseGeneratorException(String message, Throwable cause) {
		super(message, cause);
	}

	public LicenseGeneratorException(String message) {
		super(message);
	}

	public LicenseGeneratorException(Throwable cause) {
		super(cause);
	}

}
