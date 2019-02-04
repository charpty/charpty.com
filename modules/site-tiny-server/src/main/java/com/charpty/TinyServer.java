package com.charpty;

import java.io.IOException;

import com.charpty.server.BootContext;
import com.charpty.server.BootStrap;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:00
 */
public class TinyServer {

    public static void main(String[] args) throws IOException {
        BootContext context = BootContext.buildBootContext(args);
        BootStrap.listen(context);
    }
}
