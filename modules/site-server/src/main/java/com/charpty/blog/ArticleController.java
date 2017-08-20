package com.charpty.blog;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

/**
 * @author CaiBo
 * @version $Id$
 * @since 2017/8/20 上午10:19
 */
@RestController
@RequestMapping
public class ArticleController {

	@RequestMapping(value = "/articles", method = RequestMethod.GET)
	public List<Article> listArticle() {
		return getTestAricle();
	}

	private List<Article> getTestAricle() {
		List<Article> result = new ArrayList<Article>();
		for(int i=0;i<5;i++) {
			Article a1 = new Article();
			a1.setTitle("文章标题"+i);
			a1.setContent("");
		}
		return result;
	}

}
