package com.charpty.util;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/9/17 下午10:34
 */
public class PageableForm {

	private int start = -1;
	private int limit;

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
