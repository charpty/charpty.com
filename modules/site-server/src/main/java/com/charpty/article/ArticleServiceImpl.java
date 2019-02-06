package com.charpty.article;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

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

    private static final String JS_NULL = "undefined";
    private static final Set<Integer> VIEWED_FILTERS = new HashSet<>();

    @Autowired
    private ArticleMetaMapper articleMetaMapper;
    @Autowired
    private ArticleContentMapper articleContentMapper;

    @Override
    public List<ArticleMeta> listArticles(ArticleForm form) {
        checkAndResetArticleForm(form);
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
    public long countArticles(ArticleForm form) {
        return articleMetaMapper.countArticles(form);
    }

    private void checkAndResetArticleForm(ArticleForm form) {
        if (form.getLimit() > 500) {
            form.setLimit(500);
        }
        String groupName = form.getGroupName();
        if (groupName != null && (groupName.isEmpty() || JS_NULL.equals(groupName))) {
            form.setGroupName(null);
        }
    }
}
