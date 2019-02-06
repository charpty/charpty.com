package com.charpty.handlers;

import com.charpty.server.BootDataSource;

/**
 * @author charpty
 * @version $Id$
 * @since Feb 06, 2019 11:46
 */
public class ArticleDBHelper {

    static final String SQL_ARTICLE;
    static final String SQL_ARTICLE_BRIEF;

    static final String COMMON_COLUMN = "ID,NAME";
    static final String META_UQ_COLUMN = "TYPE,STATUS,TITLE,TAG,SUMMARY,COVER_IMAGE,GROUP_NAME,"
            + "CREATOR,CREATION_DATE,MODIFICATION_DATE,DISPLAY_ORDER,PINGED,PRAISED,WORD_COUNT,"
            + "COMMENT_STATUS,COMMENT_COUNT,REVISION";
    static final String META_COLUMN = COMMON_COLUMN + "," + META_UQ_COLUMN;
    static final String META_CONDITION = " FROM ARTICLE_META WHERE STATUS > 0 AND STATUS < 20";

    static {
        StringBuilder sb = new StringBuilder(1024);
        sb.append(" FROM ARTICLE_META meta LEFT JOIN ARTICLE_CONTENT content ON meta.name = content.name");
        sb.append(" WHERE meta.NAME = ?");
        String COMMON_META_JOIN = sb.toString();

        sb.setLength(0);
        sb.append("SELECT meta.ID,meta.NAME,CONTENT").append(META_UQ_COLUMN);
        sb.append(COMMON_META_JOIN);
        SQL_ARTICLE = sb.toString();

        sb.setLength(0);
        sb.append("SELECT TITLE,LEFT(CONTENT,1024) as CONTENT,CREATOR,CREATION_DATE,WORD_COUNT");
        sb.append(COMMON_META_JOIN);
        SQL_ARTICLE_BRIEF = sb.toString();
    }

    public static Article listArticles(BootDataSource dataSource, ArticleForm form) {
        StringBuilder sb = new StringBuilder(128);
        sb.append("SELECT ").append(COMMON_COLUMN).append(META_CONDITION);
        BootDataSource.PreparedStatementWrapper statement = buildCommonArticlesStatement(sb, dataSource, form);
        BootDataSource.ResultSetWrapper rs = statement.executeQuery();
        return rs.toBean(Article.class);
    }

    public static int countArticles(BootDataSource dataSource, ArticleForm form) {
        StringBuilder sb = new StringBuilder(128);
        sb.append("SELECT COUNT(*)").append(META_CONDITION);
        BootDataSource.PreparedStatementWrapper statement = buildCommonArticlesStatement(sb, dataSource, form);
        BootDataSource.ResultSetWrapper rs = statement.executeQuery();
        return rs.toInt();
    }

    private static BootDataSource.PreparedStatementWrapper buildCommonArticlesStatement(StringBuilder sb,
            BootDataSource dataSource, ArticleForm form) {
        String groupName = form.getGroupName();
        int type = form.getType();
        int start = form.getStart();
        int limit = form.getLimit();

        if (groupName != null) {
            sb.append(" AND GROUP_NAME = ?");
        }
        if (type > -1) {
            sb.append(" AND TYPE = ?");
        }
        sb.append(" ORDER BY DISPLAY_ORDER,MODIFICATION_DATE DESC");
        if (start > -1) {
            sb.append("LIMIT ?, ?");
        }
        BootDataSource.PreparedStatementWrapper statement = dataSource.preparedStatement(sb.toString());
        int index = 1;
        if (groupName != null) {
            statement.setString(index++, groupName);
        }
        if (type > -1) {
            statement.setInt(index++, type);
        }
        if (start > -1) {
            statement.setInt(index++, start);
            statement.setInt(index++, limit);
        }
        return statement;
    }

    public static Article getArticle(BootDataSource dataSource, String name) {
        BootDataSource.PreparedStatementWrapper statement = dataSource.preparedStatement(SQL_ARTICLE);
        statement.setString(1, name);
        BootDataSource.ResultSetWrapper rs = statement.executeQuery();
        return rs.toBean(Article.class);
    }

    public static Article getArticleBrief(BootDataSource dataSource, String name) {
        BootDataSource.PreparedStatementWrapper statement = dataSource.preparedStatement(SQL_ARTICLE_BRIEF);
        statement.setString(1, name);
        BootDataSource.ResultSetWrapper rs = statement.executeQuery();
        return rs.toBean(Article.class);
    }
}
