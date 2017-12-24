package com.charpty.boot;

import java.util.Map;
import java.util.concurrent.Callable;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:05
 */
public class BootOption {

	private int port = 5566;
	private Map<String, Callable<String>> controllers;

	public int getPort() {
		return port;
	}

	public void setPort(int port) {
		this.port = port;
	}

	public Map<String, Callable<String>> getControllers() {
		return controllers;
	}

	public void setControllers(Map<String, Callable<String>> controllers) {
		this.controllers = controllers;
	}
}
