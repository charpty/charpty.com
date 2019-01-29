package com.charpty.article;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

/**
 * The interface Article service.
 *
 * @author CaiBo
 * @version $Id$
 * @since 2017 /8/20 下午7:59
 */
public interface ArticleService {

    List<ArticleMeta> listArticles(ArticleForm form);

    Article getArticle(String name);

    Article getBriefArticle(String name);

    long countArticles(ArticleForm form);

    void incrPinged(Article article, HttpServletRequest request);
}
