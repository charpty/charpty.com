package com.charpty.config;

import com.charpty.config.mvc.AppWebMvcBaseConfig;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.FilterType;
import org.springframework.stereotype.Controller;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/14 下午9:50
 */
@Configuration
@ComponentScan(basePackages = "com.charpty", excludeFilters = { //
		@ComponentScan.Filter({ Controller.class }), //
		@ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE, value = AppWebMvcBaseConfig.class) })
public class ServiceConfig {
}
