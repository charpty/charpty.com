package com.charpty.boot;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:05
 */
public final class BootOptions {

	private BootOptions() {
		super();
	}

	public static BootOption getBootOption(String[] args) {
		BootOption result = new BootOption();
		return result;
	}
}
