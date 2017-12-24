package com.charpty;

import java.io.IOException;
import java.nio.channels.Selector;
import java.util.Map;
import java.util.concurrent.Callable;
import com.charpty.boot.BootOption;
import com.charpty.boot.BootOptions;
import com.charpty.boot.BootStrap;
import com.charpty.boot.ControllerAction;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:00
 */
public class TinyServer {

	public static void main(String[] args) throws IOException {
		BootOption bootOption = BootOptions.getBootOption(args);
		Selector selector = BootStrap.listen(bootOption);
		Map<String, Callable<String>> controllers = BootStrap.getServerControllers(bootOption);
		bootOption.setControllers(controllers);
		System.out.println("*******start the server...");
		BootStrap.aeMain(selector, bootOption);
	}
}
