package com.charpty.blog;

/**
 * @author CaiBo
 * @version $Id$
 * @since 2017/8/20 上午10:20
 */
public class Article {

	private String title;
	private String summary;
	private String content;
	private int readingAmount;

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getSummary() {
		return summary;
	}

	public void setSummary(String summary) {
		this.summary = summary;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public int getReadingAmount() {
		return readingAmount;
	}

	public void setReadingAmount(int readingAmount) {
		this.readingAmount = readingAmount;
	}
}
