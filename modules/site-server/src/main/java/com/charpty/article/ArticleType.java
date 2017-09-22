package com.charpty.article;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/9/22 下午10:12
 */
public enum ArticleType {
	/**
	 *
	 */
	NORMAL(10, "普通文章"),

	/**
	 *
	 */
	ESSAY(20, "个人随记");

	private int type;
	private String description;

	ArticleType(int type, String description) {
		this.type = type;
		this.description = description;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}
}
