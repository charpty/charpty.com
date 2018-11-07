package com.charpty.article.mapper;

import com.charpty.article.Article;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/9/17 下午10:33
 */
public interface ArticleContentMapper {

    String getContent(String name);

    Article getArticle(String name);

    Article getBriefArticle(String name);
}
