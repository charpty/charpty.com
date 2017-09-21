-- 文章列表
DROP TABLE IF EXISTS ARTICLE;
CREATE TABLE ARTICLE (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `NAME` varchar(50) NOT NULL COMMENT '文章名称唯一标识，用于防止数据迁移',
  `TYPE` int(4) unsigned NOT NULL DEFAULT 10 COMMENT '文章类别，10：普通文章，20：个人随记',
  `STATUS` tinyint(4) NOT NULL DEFAULT 10 COMMENT '文章状态，0：草稿箱，10：已发布 20：已删除',
  `TITLE` varchar(30) NOT NULL COMMENT '文章标题',
  `TAG` varchar(50) NOT NULL COMMENT '文章标签，可多个，空格分开',
  `SUMMARY` varchar(300) NOT NULL COMMENT '文章摘要',
  `COVER_IMAGE` varchar(100) NULL COMMENT '封面图片地址',
  `CONTENT` text NOT NULL COMMENT '文章内容',
  `GROUP_NAME` varchar(30) NOT NULL DEFAULT 'unclassified' COMMENT '组别名称',
  `CREATOR` varchar(30) NOT NULL COMMENT '创建者',
  `CREATION_DATE` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `MODIFICATION_DATE` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
  `DISPLAY_ORDER` int NOT NULL DEFAULT 0 COMMENT  '展示顺序，越小越靠后',
  `PINGED` int NOT NULL DEFAULT -1 COMMENT '文章的点击量',
  `PRAISED` int NOT NULL DEFAULT -1 COMMENT '文章的点赞数量',
  `WORD_COUNT` int NOT NULL DEFAULT -1 COMMENT '文章字数,内容过长时不便统计，-1表示在程序中统计',
  `COMMENT_STATUS` tinyint(4) unsigned NOT NULL DEFAULT 20 COMMENT '评论状态，0：评论关闭且不显示已有评论，10：可评论但不显示其他评论 20：可评论并显示所有评论',
  `COMMENT_COUNT` int(11) unsigned NOT NULL DEFAULT -1 COMMENT '文章评论数量统计',
  `REVISION` smallint(6) unsigned NOT NULL DEFAULT 0 COMMENT '修订版本',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `ID_UNIQUE` (`ID`),
  UNIQUE KEY `NAME_UNIQUE` (`NAME`)
) ENGINE=InnoDB AUTO_INCREMENT=1000 DEFAULT CHARSET=utf8;


