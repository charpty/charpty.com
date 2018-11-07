package com.charpty.article;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.Assert;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import com.google.gson.Gson;

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
    public List<ArticleMeta> listArticles(ArticleForm form) {
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
        Assert.notNull(name, "article name can not be null");
        Article article = articleService.getArticle(name);
        return article;
    }

    @RequestMapping(value = "/article/content/{name}", method = RequestMethod.GET)
    public Article getContent(@PathVariable("name") String name) {
        Assert.notNull(name, "article name can not be null");
        Article article = articleService.getArticle(name);
        return article;
    }

    @RequestMapping(value = "/article/brief/{name}", method = RequestMethod.GET)
    public Article getArticleBrief(@PathVariable("name") String name) {
        Assert.notNull(name, "article name can not be null");
        Article article = articleService.getBriefArticle(name);
        System.out.println(new Gson().toJson(article));
        return article;
    }

}
