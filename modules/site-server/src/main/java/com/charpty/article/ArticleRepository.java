package com.charpty.article;

import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.PagingAndSortingRepository;

/**
 * @author CaiBo
 * @version $Id$
 * @since 2017/8/20 下午7:57
 */
public interface ArticleRepository extends PagingAndSortingRepository<Article, Long> {
}
