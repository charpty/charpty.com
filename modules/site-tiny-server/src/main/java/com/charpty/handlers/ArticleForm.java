package com.charpty.handlers;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/9/17 下午10:35
 */
public class ArticleForm {

    private int type = ArticleType.NORMAL.getType();
    private String groupName;
    private int start = 0;
    private int limit = 5;

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public String getGroupName() {
        return groupName;
    }

    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    public int getStart() {
        return start;
    }

    public void setStart(int start) {
        this.start = start;
    }

    public int getLimit() {
        return limit;
    }

    public void setLimit(int limit) {
        this.limit = limit;
    }
}
