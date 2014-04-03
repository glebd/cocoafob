package com.xk72.cocoafob;

/**
 * Represents the data used as the string data input to the CocoaFob algorithm. Extend this class
 * and override {@link LicenseData#toLicenseStringData()} to customise the string data to match your application.
 * @author karlvr
 *
 */
public class LicenseData {

	protected String productCode;
	protected String name;
	protected String email;
	
	protected LicenseData() {
		super();
	}

	public LicenseData(String productCode, String name) {
		super();
		this.productCode = productCode;
		this.name = name;
	}

	public LicenseData(String productCode, String name, String email) {
		super();
		this.productCode = productCode;
		this.name = name;
		this.email = email;
	}

	public String getProductCode() {
		return productCode;
	}

	public void setProductCode(String productCode) {
		this.productCode = productCode;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}
	
	/**
	 * Returns the string data input for the CocoaFob algorithm. This implementation returns a comma separated string
	 * including the {@link #productCode}, {@link #name} and {@link #email} if set.
	 * @return
	 */
	public String toLicenseStringData() {
		StringBuilder result = new StringBuilder();
		result.append(productCode);
		result.append(',');
		result.append(name);
		if (email != null) {
			result.append(',');
			result.append(email);
		}
		return result.toString();
	}
	
}
