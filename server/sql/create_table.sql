-- 文章列表
DROP TABLE IF EXISTS ARTICLE;
CREATE TABLE ARTICLE (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `TITLE` varchar(30) NOT NULL COMMENT '文章标题',
  `TAG` varchar(50) NOT NULL COMMENT '文章标签',
  `SUMMARY` varchar(100) NOT NULL COMMENT '文章摘要',
  `CONTENT` text NOT NULL COMMENT '文章内容',
  `CREATOR` varchar(30) NOT NULL COMMENT '创建者',
  `CREATION_DATE` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DISPLAY_ORDER` int NOT NULL DEFAULT 0 COMMENT  '展示顺序，越小越靠后',
  `REVISION` int(11) NOT NULL DEFAULT '0' COMMENT '修订版本',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `ID_UNIQUE` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1000 DEFAULT CHARSET=utf8;

