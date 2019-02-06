package com.charpty.handlers;

import java.util.List;
import java.util.Map;

import com.charpty.server.BootContext;
import com.charpty.server.HTTPRequest;
import com.charpty.server.RequestHandler;
import com.charpty.server.ResponseUtil;

/**
 * @author charpty
 * @since 2017/12/24
 */
public class ArticleHandler implements RequestHandler {

    private static final String ARTICLES_PATH = "/articles";
    private static final int ARTICLES_PATH_LEN = ARTICLES_PATH.length();
    private static final String ARTICLES_COUNT_PART = "/count";
    private static final String ARTICLE_PATH = "/article/";
    private static final int ARTICLE_PATH_LEN = ARTICLE_PATH.length();
    private static final String ARTICLE_BRIEF_PART = "brief/";
    private static final int ARTICLE_BRIEF_LEN = ARTICLE_PATH_LEN + ARTICLE_BRIEF_PART.length();

    @Override
    public String handle(HTTPRequest request) {
        String path = request.getPath();
        if (path.startsWith(ARTICLES_PATH)) {
            // => /articles/count
            if (path.startsWith(ARTICLES_COUNT_PART, ARTICLES_PATH_LEN)) {
                return countArticles(request);
            }
            // => /articles
            return listArticles(request);
        } else if (path.startsWith(ARTICLE_PATH)) {
            BootContext context = request.getContext();
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
        ArticleForm form = getArticleForm(request);
        List<Article> articles = ArticleDBHelper.listArticles(request.getContext().getDataSource(), form);
        return ResponseUtil.toResponse(articles);
    }

    public String countArticles(HTTPRequest request) {
        ArticleForm form = getArticleForm(request);
        int count = ArticleDBHelper.countArticles(request.getContext().getDataSource(), form);
        return String.valueOf(count);
    }

    public String getArticle(BootContext context, String name) {
        Article article = ArticleDBHelper.getArticle(context.getDataSource(), name);
        return ResponseUtil.toResponse(article);
    }

    public String getArticleBrief(BootContext context, String name) {
        Article article = ArticleDBHelper.getArticleBrief(context.getDataSource(), name);
        return ResponseUtil.toResponse(article);
    }

    private ArticleForm getArticleForm(HTTPRequest request) {
        ArticleForm form = new ArticleForm();
        Map<String, String> params = request.getParams();
        if (params == null) {
            return form;
        }
        String type = params.get("type");
        if (type != null) {
            form.setType(Integer.valueOf(type));
        }
        String start = params.get("start");
        if (start != null) {
            form.setStart(Integer.valueOf(start));
            form.setLimit(Integer.valueOf(params.get("limit")));
        }
        form.setGroupName(params.get("groupName"));
        return form;
    }

}
