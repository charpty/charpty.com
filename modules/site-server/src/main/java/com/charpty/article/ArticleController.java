package com.charpty.article;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author CaiBo
 * @version $Id$
 * @since 2017/8/20 上午10:19
 */
@RestController
@RequestMapping
public class ArticleController {

	@Autowired
	private ArticleService articleService;

	@RequestMapping(value = "/articles", method = RequestMethod.GET)
	public List<Article> listArticles(ArticleForm form) {
		if (form.getLimit() > 500) {
			form.setLimit(500);
		}
		return articleService.listArticles(form);
	}

	@RequestMapping(value = "/articles/count", method = RequestMethod.GET)
	public long countArticles(ArticleForm form) {
		return articleService.countArticles(form);
	}

	@RequestMapping(value = "/article/{name}", method = RequestMethod.GET)
	public Article getArticle(@PathVariable("name") String name) {
		return articleService.getArticle(name);
	}

}
