package com.charpty.config.context;

import org.springframework.boot.autoconfigure.web.DispatcherServletAutoConfiguration;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.DispatcherServlet;

/**
 *
 * @author CaiBo
 * @version $Id$
 * @since 2017/8/17 下午4:31
 */
@Configuration
public class ServletMappingConfig {

	// @Bean
	// 直接使用application.properties#server.servlet-path
	public ServletRegistrationBean dispatcherServletRegistration(DispatcherServlet dispatcherServlet) {
		ServletRegistrationBean registration = new ServletRegistrationBean(dispatcherServlet, "/api/*");
		registration.setName(DispatcherServletAutoConfiguration.DEFAULT_DISPATCHER_SERVLET_REGISTRATION_BEAN_NAME);
		return registration;
	}
}
