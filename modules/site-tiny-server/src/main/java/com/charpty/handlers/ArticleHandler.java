package com.charpty.handlers;

import java.util.ArrayList;
import java.util.List;

import com.charpty.server.BootContext;
import com.charpty.server.HTTPRequest;
import com.charpty.server.RequestHandler;

/**
 * @author charpty
 * @since 2017/12/24
 */
public class ArticleHandler implements RequestHandler {

    private static final String ARTICLES_PATH = "/articles/";
    private static final int ARTICLES_PATH_LEN = ARTICLES_PATH.length();
    private static final String ARTICLES_COUNT_PART = "count";
    private static final String ARTICLE_PATH = "/article/";
    private static final int ARTICLE_PATH_LEN = ARTICLE_PATH.length();
    private static final String ARTICLE_BRIEF_PART = "brief/";
    private static final int ARTICLE_BRIEF_LEN = ARTICLE_PATH_LEN + ARTICLE_BRIEF_PART.length();

    @Override
    public String handle(HTTPRequest request) {
        String path = request.getPath();
        BootContext context = request.getContext();
        if (path.startsWith(ARTICLES_PATH)) {
            // => /articles/count
            if (path.startsWith(ARTICLES_COUNT_PART, ARTICLES_PATH_LEN)) {
                return countArticles(context);
            }
            // => /articles
            return listArticles(request);
        } else if (path.startsWith(ARTICLE_PATH)) {
            // => /article/brief/{name}
            if (path.startsWith(ARTICLE_BRIEF_PART, ARTICLE_PATH_LEN)) {
                return getArticleBrief(context, path.substring(ARTICLE_BRIEF_LEN));
            }
            // => /article/{name}
            return getArticle(context, path.substring(ARTICLE_PATH_LEN));
        }
        return null;
    }

    public String listArticles(HTTPRequest request) {
        List<Article> result = new ArrayList<>();
        return null;
    }

    public String countArticles(BootContext context) {
        return "";
    }

    public String getArticle(BootContext context, String name) {
        return null;
    }

    public String getArticleBrief(BootContext context, String name) {
        return null;
    }

}
