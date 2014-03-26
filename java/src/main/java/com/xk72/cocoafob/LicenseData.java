package com.xk72.cocoafob;

public class LicenseData {

	private String productCode;
	private String name;
	private String email;
	
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
	
	public String toLicenseStringData() {
		return productCode + "," + name + "," + email;
	}
	
}
