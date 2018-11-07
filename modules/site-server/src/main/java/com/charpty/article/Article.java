package com.charpty.article;

/**
 * @author charpty
 * @since 2018/11/4
 */
public class Article extends ArticleMeta {

    private String content;
    private boolean eof = true;

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public boolean isEof() {
        return eof;
    }

    public void setEof(boolean eof) {
        this.eof = eof;
    }
}
