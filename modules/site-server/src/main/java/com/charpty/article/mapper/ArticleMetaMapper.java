package com.charpty.article.mapper;

import java.util.List;

import com.charpty.article.ArticleForm;
import com.charpty.article.ArticleMeta;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/9/17 下午10:33
 */
public interface ArticleMetaMapper {

    List<ArticleMeta> listArticles(ArticleForm form);

    int countArticles(ArticleForm form);

}
