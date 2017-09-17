package com.charpty.article.mapper;

import java.util.List;
import com.charpty.article.Article;
import com.charpty.article.ArticleForm;
import org.apache.ibatis.annotations.Param;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/9/17 下午10:33
 */
public interface ArticleMapper {

	List<Article> listArticles(ArticleForm form);

	Article getArticle(String name);

	int countArticles(ArticleForm form);

	void updateWordCount(@Param("id") int id, @Param("wordCount") int wordCount);
}
