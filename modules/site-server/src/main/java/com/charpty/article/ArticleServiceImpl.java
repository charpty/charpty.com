package com.charpty.article;

import java.util.List;
import com.charpty.article.mapper.ArticleMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * @author CaiBo
 * @version $Id$
 * @since 2017/8/20 下午7:59
 */
@Service
public class ArticleServiceImpl implements ArticleService {

	@Autowired
	private ArticleMapper articleMapper;

	@Override
	public List<Article> listArticles(ArticleForm form) {
		List<Article> articles = articleMapper.listArticles(form);
		return articles;
	}

	@Override
	public Article getArticle(String name) {
		return articleMapper.getArticle(name);
	}

	@Override
	public long countArticles(ArticleForm form) {
		return articleMapper.countArticles(form);
	}
}
