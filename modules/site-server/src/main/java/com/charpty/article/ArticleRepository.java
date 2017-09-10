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

	@Query("SELECT new Article (id,name,type,status,title,tag,summary,coverImage,groupName,creator,creationDate,"
			+ "modificationDate,displayOrder,pinged,praised,commentStatus,commentCount,revision) FROM Article " //
			+ "WHERE status>0and status<20")
	List<Article> listArticles(Pageable pageable);

	Article findByName(String name);
}
