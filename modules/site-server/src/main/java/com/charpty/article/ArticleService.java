package com.charpty.article;

import org.springframework.data.domain.Pageable;

import java.util.List;

/**
 * The interface Article service.
 *
 * @author CaiBo
 * @version $Id$
 * @since 2017 /8/20 下午7:59
 */
public interface ArticleService {

	/**
	 * List articles list.
	 *
	 * @param pageable the pageable
	 *
	 * @return the list
	 */
	List<Article> listArticles(Pageable pageable);

	/**
	 * Gets article.
	 *
	 * @param id the id
	 *
	 * @return the article
	 */
	Article getArticle(int id);
}
