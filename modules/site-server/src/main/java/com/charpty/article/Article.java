package com.charpty.article;

import javax.persistence.Entity;
import javax.persistence.Id;
import java.util.Date;

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
	private String tag;
	private String summary;
	private String content;
	private String creator;
	private Date creationDate;
	private int displayOrder;
	private int revision;

	public Article() {

	}

	public Article(int id, String title, String tag, String summary, String creator, Date creationDate, int displayOrder, int revision) {
		this.id = id;
		this.title = title;
		this.tag = tag;
		this.summary = summary;
		this.creator = creator;
		this.creationDate = creationDate;
		this.displayOrder = displayOrder;
		this.revision = revision;
	}

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

	public String getTag() {
		return tag;
	}

	public void setTag(String tag) {
		this.tag = tag;
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

	public String getCreator() {
		return creator;
	}

	public void setCreator(String creator) {
		this.creator = creator;
	}

	public Date getCreationDate() {
		return creationDate;
	}

	public void setCreationDate(Date creationDate) {
		this.creationDate = creationDate;
	}

	public int getDisplayOrder() {
		return displayOrder;
	}

	public void setDisplayOrder(int displayOrder) {
		this.displayOrder = displayOrder;
	}

	public int getRevision() {
		return revision;
	}

	public void setRevision(int revision) {
		this.revision = revision;
	}
}
