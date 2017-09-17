package com.charpty.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/9/17 下午10:58
 */
@Configuration
@MapperScan("com.charpty.**.mapper")
public class MapperConfig {
}
