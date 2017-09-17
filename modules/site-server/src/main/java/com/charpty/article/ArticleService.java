package com.charpty.article;

import java.util.List;

/**
 * The interface Article service.
 *
 * @author CaiBo
 * @version $Id$
 * @since 2017 /8/20 下午7:59
 */
public interface ArticleService {

	List<Article> listArticles(ArticleForm form);

	Article getArticle(String name);

	long countArticles(ArticleForm form);
}
