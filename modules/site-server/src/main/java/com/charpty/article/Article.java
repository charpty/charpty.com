package com.charpty.article;

import javax.persistence.Entity;
import javax.persistence.Id;

/**
 * @author CaiBo
 * @version $Id$
 * @since 2017/8/20 上午10:20
 */
@Entity
public class Article {

	@Id
	private int id;
	private String title;
	private String summary;
	private String content;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

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

}
