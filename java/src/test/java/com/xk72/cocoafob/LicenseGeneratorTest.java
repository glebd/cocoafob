package com.xk72.cocoafob;

import java.io.IOException;

import org.junit.Assert;
import org.junit.Test;

public class LicenseGeneratorTest {

	@Test
	public void testPrivateKey() throws IOException {
		LicenseGenerator lg = new LicenseGenerator(getClass().getResource("privkey.pem"));
		Assert.assertTrue(lg.isCanMakeLicenses());
		Assert.assertTrue(lg.isCanVerifyLicenses());
	}

	@Test
	public void testPublicKey() throws IOException {
		LicenseGenerator lg = new LicenseGenerator(getClass().getResource("pubkey.pem"));
		Assert.assertFalse(lg.isCanMakeLicenses());
		Assert.assertTrue(lg.isCanVerifyLicenses());
	}
	
	@Test
	public void testMakeLicense() throws IOException, IllegalStateException, LicenseGeneratorException {
		LicenseGenerator lg = new LicenseGenerator(getClass().getResource("privkey.pem"));
		String license = lg.makeLicense(new LicenseData("Test", "Karl", "karl@example.com"));
		Assert.assertTrue(license.length() > 0);
	}
	
	@Test
	public void testVerifyLicense() throws IOException, IllegalStateException, LicenseGeneratorException {
		LicenseGenerator lg = new LicenseGenerator(getClass().getResource("privkey.pem"));
		LicenseData licenseData = new LicenseData("Test", "Karl", "karl@example.com");
		String license = lg.makeLicense(licenseData);
		boolean verified = lg.verifyLicense(licenseData, license);
		Assert.assertTrue(verified);
	}
	
	@Test
	public void testVerifyLicense2() throws IOException, IllegalStateException, LicenseGeneratorException {
		LicenseGenerator lg = new LicenseGenerator(getClass().getResource("privkey.pem"));
		LicenseData licenseData = new LicenseData("Test", "Karl");
		String license = lg.makeLicense(licenseData);
		boolean verified = lg.verifyLicense(licenseData, license);
		Assert.assertTrue(verified);
	}
	
	@Test
	public void testFailedVerifyLicense() throws IOException, IllegalStateException, LicenseGeneratorException {
		LicenseGenerator lg = new LicenseGenerator(getClass().getResource("privkey.pem"));
		LicenseData licenseData = new LicenseData("Test", "Karl");
		Assert.assertTrue(lg.verifyLicense(licenseData, "GAWQE-F9AVF-8YSF3-NBDUH-C6M2J-JYAYC-X692H-H65KR-A9KAQ-R9SB7-A374H-T6AH3-87TAB-CVV6K-SKUGG-A"));
		Assert.assertFalse(lg.verifyLicense(licenseData, "GAWQE-F9AVF-8YSF3-NBDUH-C6M2J-JYAYC-X692H-H65KR-A9KAQ-R9SB7-A374H-T6AH3-87TAB-CVV6K-SKAGG-A"));
		Assert.assertFalse(lg.verifyLicense(licenseData, "GAWQE-F9AVF-8YSF3-NBDUH-C6M2J-JYAYC-X692H-H65KR-A9KAQ-R9SB7-A374H-T6AH3-87TAB-DVV6K-SKUGG-A"));
	}
	
}
