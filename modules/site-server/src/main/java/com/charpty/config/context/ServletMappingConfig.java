package com.charpty.config.context;

import javax.servlet.ServletContext;
import com.charpty.config.mvc.AppWebMvcBaseConfig;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.autoconfigure.web.DispatcherServletAutoConfiguration;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.boot.web.servlet.ServletContextInitializer;
import org.springframework.boot.web.servlet.ServletListenerRegistrationBean;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.FilterType;
import org.springframework.stereotype.Controller;
import org.springframework.web.context.request.RequestContextListener;
import org.springframework.web.context.support.AnnotationConfigWebApplicationContext;
import org.springframework.web.filter.CharacterEncodingFilter;
import org.springframework.web.servlet.DispatcherServlet;

/**
 * @author CaiBo
 * @version $Id$
 * @since 2017/8/17 下午4:31
 */
@Configuration
public class ServletMappingConfig {

	@Bean
	public ServletContextInitializer initializer() {
		return (servletContext) -> {
			servletContext.setInitParameter("URIEncoding", "UTF-8");
			servletContext.setInitParameter("contextClass", AnnotationConfigWebApplicationContext.class.getName());
			servletContext.setInitParameter("shutdown-on-unload", "true");
			servletContext.setInitParameter("wait-on-shutdown", "false");
			servletContext.setInitParameter("shutdown-on-unload", "true");
			servletContext.setInitParameter("wait-on-shutdown", "false");
			setContextInitParameter(servletContext);
		};
	}

	public void setContextInitParameter(ServletContext servletContext) {

	}

	@Bean
	@ConditionalOnMissingBean(DispatcherServlet.class)
	public ServletRegistrationBean dispatcherServletRegistration() {
		DispatcherServlet dispatcherServlet = new DispatcherServlet();
		dispatcherServlet.setContextConfigLocation(AppWebMvcBaseConfig.class.getName());
		dispatcherServlet.setContextClass(AnnotationConfigWebApplicationContext.class);
		ServletRegistrationBean registration = new ServletRegistrationBean(dispatcherServlet, "/api/*");
		registration.setName(DispatcherServletAutoConfiguration.DEFAULT_DISPATCHER_SERVLET_REGISTRATION_BEAN_NAME);
		registration.setLoadOnStartup(1);
		return registration;
	}

	@Bean
	public FilterRegistrationBean characterEncodingFilterRegistration() {
		FilterRegistrationBean registration = new FilterRegistrationBean();
		registration.setFilter(new CharacterEncodingFilter());
		registration.addInitParameter("encoding", "UTF-8");
		registration.addUrlPatterns("/*");
		registration.setOrder(1);
		return registration;
	}

	@Bean
	@ConditionalOnMissingBean(RequestContextListener.class)
	public ServletListenerRegistrationBean requestContextListener() {
		ServletListenerRegistrationBean registration = new ServletListenerRegistrationBean();
		registration.setListener(new RequestContextListener());
		registration.setOrder(3);
		return registration;
	}
}
