package com.charpty.article;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

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
	public List<Article> listArticles(@PageableDefault(value = 7) Pageable pageable) {
		return articleService.listArticles(pageable);
	}

	@RequestMapping(value = "/article/{id}", method = RequestMethod.GET)
	public Article getArticle(@PathVariable("id") int id) {
		Article r = articleService.getArticle(id);
		return r;
	}

}
