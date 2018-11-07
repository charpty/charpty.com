package com.charpty.article;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.charpty.article.mapper.ArticleContentMapper;
import com.charpty.article.mapper.ArticleMetaMapper;

/**
 * @author CaiBo
 * @version $Id$
 * @since 2017/8/20 下午7:59
 */
@Service
public class ArticleServiceImpl implements ArticleService {

    @Autowired
    private ArticleMetaMapper articleMetaMapper;
    @Autowired
    private ArticleContentMapper articleContentMapper;

    @Override
    public List<ArticleMeta> listArticles(ArticleForm form) {
        return articleMetaMapper.listArticles(form);
    }

    @Override
    public Article getArticle(String name) {
        return articleContentMapper.getArticle(name);
    }

    @Override
    public Article getBriefArticle(String name) {
        return articleContentMapper.getBriefArticle(name);
    }

    @Override
    public String content(String name) {
        return articleContentMapper.getContent(name);
    }

    @Override
    public long countArticles(ArticleForm form) {
        return articleMetaMapper.countArticles(form);
    }
}
