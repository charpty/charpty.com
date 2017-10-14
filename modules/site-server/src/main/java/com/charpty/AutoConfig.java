package com.charpty;

import org.springframework.boot.autoconfigure.context.PropertyPlaceholderAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.web.EmbeddedServletContainerAutoConfiguration;
import org.springframework.boot.autoconfigure.web.ErrorMvcAutoConfiguration;
import org.springframework.boot.autoconfigure.web.HttpEncodingAutoConfiguration;
import org.springframework.boot.autoconfigure.web.HttpMessageConvertersAutoConfiguration;
import org.springframework.boot.autoconfigure.web.MultipartAutoConfiguration;
import org.springframework.boot.autoconfigure.web.ServerPropertiesAutoConfiguration;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/9/15 下午3:48
 */
@Configuration
@Import({ EmbeddedServletContainerAutoConfiguration.class, //
		ErrorMvcAutoConfiguration.class, //
		HttpEncodingAutoConfiguration.class, //
		HttpMessageConvertersAutoConfiguration.class, //
		MultipartAutoConfiguration.class, //
		ServerPropertiesAutoConfiguration.class, //
		PropertyPlaceholderAutoConfiguration.class, //
		DataSourceAutoConfiguration.class //
})
public class AutoConfig {

}
