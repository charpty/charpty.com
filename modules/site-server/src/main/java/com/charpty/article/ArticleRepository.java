package com.charpty.article;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.PagingAndSortingRepository;

import java.util.List;

/**
 * @author CaiBo
 * @version $Id$
 * @since 2017/8/20 下午7:57
 */
public interface ArticleRepository extends PagingAndSortingRepository<Article, Integer> {

	@Query("SELECT new Article (id,title,tag,summary,creator,creationDate,displayOrder,revision) FROM Article")
	List<Article> listArticles(Pageable pageable);
}
