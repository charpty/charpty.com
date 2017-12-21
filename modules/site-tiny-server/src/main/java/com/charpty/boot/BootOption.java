package com.charpty.boot;

import java.util.Map;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:05
 */
public class BootOption {

	private int port = 5566;
	private Map<String, Runnable> controllers;

	public int getPort() {
		return port;
	}

	public void setPort(int port) {
		this.port = port;
	}

	public Map<String, Runnable> getControllers() {
		return controllers;
	}

	public void setControllers(Map<String, Runnable> controllers) {
		this.controllers = controllers;
	}
}
