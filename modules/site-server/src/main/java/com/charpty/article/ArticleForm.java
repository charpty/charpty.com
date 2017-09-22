package com.charpty.article;

import com.charpty.util.PageableForm;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/9/17 下午10:35
 */
public class ArticleForm extends PageableForm {

	private int type = ArticleType.NORMAL.getType();
	private String groupName;

	public String getGroupName() {
		return groupName;
	}

	public void setGroupName(String groupName) {
		this.groupName = groupName;
	}
}
