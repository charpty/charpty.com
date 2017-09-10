package com.charpty.article;

import com.google.common.collect.Lists;
import com.tomato.util.NumberUtil;
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
	public Article getArticle(String idOrName) {
		Article result = null;
		try {
			int idLong = Integer.valueOf(idOrName);
			result = articleRepository.findOne(idLong);
		} catch (NumberFormatException ignore) {
			result = articleRepository.findByName(idOrName);
		}
		if (result != null && result.getWordCount() < 0) {
			result.setWordCount(result.getContent().length());
		}
		return result;
	}

	@Override
	public long countArticles() {
		return articleRepository.count();
	}
}
