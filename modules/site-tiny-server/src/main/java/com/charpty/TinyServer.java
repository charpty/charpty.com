package com.charpty;

import java.io.IOException;
import java.nio.channels.Selector;
import java.util.Map;
import com.charpty.boot.BootOption;
import com.charpty.boot.BootOptions;
import com.charpty.boot.BootStrap;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:00
 */
public class TinyServer {

	public static void main(String[] args) throws IOException {
		BootOption bootOption = BootOptions.getBootOption(args);
		Selector selector = BootStrap.listen(bootOption);
		Map<String, Runnable> controllers = BootStrap.getServerControllers(bootOption);
		bootOption.setControllers(controllers);
		BootStrap.aeMain(selector, bootOption);
	}
}
