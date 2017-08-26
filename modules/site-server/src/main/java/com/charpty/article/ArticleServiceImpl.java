package com.charpty.article;

import com.google.common.collect.Lists;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author CaiBo
 * @version $Id$
 * @since 2017/8/20 下午7:59
 */
@Service
public class ArticleServiceImpl implements ArticleService {

	@Autowired
	private ArticleRepository articleRepository;

	@Override
	public List<Article> listArticles(Pageable pageable) {
		List<Article> result = articleRepository.listArticles(pageable);
		return result;
	}

	@Override
	public Article getArticle(int id) {
		return articleRepository.findOne(id);
	}
}
