package com.charpty;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.charpty.handlers.ArticleHandler;
import com.charpty.handlers.DailyWordHandler;
import com.charpty.server.BootContext;
import com.charpty.server.BootDataSource;
import com.charpty.server.BootStrap;
import com.charpty.server.RequestHandler;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:00
 */
public class TinyServer {

    static final List<RequestHandler> HANDLERS = new ArrayList<>();

    static {
        HANDLERS.add(new DailyWordHandler());
        HANDLERS.add(new ArticleHandler());
    }

    public static void main(String[] args) throws IOException {
        BootContext context = BootContext.buildBootContext(args);
        context.setHandlers(HANDLERS);
        context.setDataSource(new BootDataSource(System.getProperty("db.url")));
        BootStrap.listen(context);
    }

}
