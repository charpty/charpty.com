package com.charpty.config.mvc;

import com.google.gson.GsonBuilder;
import com.google.gson.JsonSyntaxException;
import com.google.gson.TypeAdapter;
import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonToken;
import com.google.gson.stream.JsonWriter;
import com.tomato.util.BooleanUtil;
import com.tomato.util.NumberUtil;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.security.SecurityAutoConfiguration;
import org.springframework.boot.autoconfigure.web.WebMvcAutoConfiguration;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.support.ReloadableResourceBundleMessageSource;
import org.springframework.data.web.config.EnableSpringDataWebSupport;
import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.converter.json.GsonHttpMessageConverter;
import org.springframework.validation.Validator;
import org.springframework.validation.beanvalidation.OptionalValidatorFactoryBean;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.support.ConfigurableWebBindingInitializer;
import org.springframework.web.servlet.config.annotation.*;
import org.springframework.web.servlet.mvc.WebContentInterceptor;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * @author CaiBo
 * @version $Id$
 * @since 2017年7月14日 上午11:24:17
 */
@Configuration
@EnableSpringDataWebSupport
@EnableWebMvc
@EnableAutoConfiguration(exclude = SecurityAutoConfiguration.class)
public class AppWebMvcBaseConfig extends WebMvcConfigurerAdapter {

	/**
	 * Form 表单验证消息本地化资源处理
	 */
	private static String MESSAGE_SOURCE_DEFAULT_ENCODING = "UTF-8";
	private String[] messageSourceBasenames = { "classpath:ValidationMessages" };
	/**
	 * JSON 序列化/反序列化时本地化需求处理
	 */
	private static String UNIFIED_DATE_FORMAT = "yyyy-MM-dd HH:mm:ss";
	private static final TypeAdapter<BigDecimal> BIG_DECIMAL;
	private static final int POOR_SCALE_MIN = NumberUtil.POOR_SCALE_MIN;
	/**
	 * CROSS 浏览器跨域允许的方法定义
	 */
	private static final String[] CROSS_DOMAIN_ALLOWED_METHOD;

	// TODO 如果使用AppConfig.getConfig()则会由于调用数据库导致druid死锁？？
	// TODO 我更多的认为是druid或我们的AppContext在获取数据库DataSource的方式上可能存在瑕疵
	// TODO 加载mvc config时前置的所有配置bean和service bean都已经加载完毕了
	// TODO 除非业务模块配置了自己的扫描方式或提前加载了AppWebMvcConfig
	private static final boolean STRICT_SUFFIX_MATCH = BooleanUtil.getBoolean("rap.mvc.match.regsuffix", true);

	/**
	 * @param basenames
	 */
	public void addMessageSourceBasenames(String... basenames) {
		List<String> list = new ArrayList<>(Arrays.asList(messageSourceBasenames));
		for (String basename : basenames) {
			if (!list.contains(basename)) {
				list.add(basename);
			}
		}
		messageSourceBasenames = list.toArray(new String[list.size()]);
	}

	@Override
	public Validator getValidator() {
		ReloadableResourceBundleMessageSource messageSource = new ReloadableResourceBundleMessageSource();
		messageSource.setDefaultEncoding(MESSAGE_SOURCE_DEFAULT_ENCODING);
		messageSource.setBasenames(messageSourceBasenames);
		OptionalValidatorFactoryBean validator = new OptionalValidatorFactoryBean();
		validator.setValidationMessageSource(messageSource);
		return validator;
	}

	@Override
	public void configurePathMatch(PathMatchConfigurer configurer) {
		// 禁止(/user.abc == /user.efg == /user)
		configurer.setUseSuffixPatternMatch(false);
		// 禁止(/user == /user/)
		configurer.setUseTrailingSlashMatch(false);
		// 仅使用在(#configureContentNegotiation)配置中指定的尾缀匹配
		// (/user.abc存在)?/user.abc:404 (/user.do存在)?/user.do:/user
		if (STRICT_SUFFIX_MATCH) {
			configurer.setUseRegisteredSuffixPatternMatch(true);
		}
		// 在获取匹配路径时就快速去除已认可的尾缀(.do等)可提高匹配效率
		// 但是Spring将此设计为一个类而非接口, 似乎不太想开发者自行编写, 只是出于无奈放出口子
		// configurer.setUrlPathHelper(new AppUrlPathHelper());

		// configurer.setPathMatcher(new AppPathMatcher(ALLOW_WELL_KNOW_PATH_SUFFIX));
	}

	@Override
	public void configureContentNegotiation(ContentNegotiationConfigurer configurer) {
		configurer.defaultContentType(MediaType.APPLICATION_JSON_UTF8);
		configurer.favorPathExtension(false);
		configurer.favorParameter(true);
		configurer.ignoreUnknownPathExtensions(true);

		configurer.mediaType("json", MediaType.APPLICATION_JSON_UTF8);
		configurer.mediaType("xml", MediaType.APPLICATION_XML);
		configurer.mediaType("do", MediaType.ALL);
	}

	@Override
	public void addCorsMappings(CorsRegistry registry) {
		// TODO 以下参数建议配置+默认解决
		// .addMapping("/api/**").allowedOrigins("*")
		// .allowedMethods("*").allowedHeaders("*")
		// .exposedHeaders().allowCredentials(false).maxAge(3600);
		CorsRegistration registration = registry.addMapping("/**");
		registration.allowCredentials(true).maxAge(3600);
		registration.allowedMethods(CROSS_DOMAIN_ALLOWED_METHOD);
	}

	static {
		BIG_DECIMAL = new TypeAdapter<BigDecimal>() {
			@Override
			public BigDecimal read(JsonReader in) throws IOException {
				if (in.peek() == JsonToken.NULL) {
					in.nextNull();
					return null;
				}
				try {
					BigDecimal value = new BigDecimal(in.nextString());
					int scale = value.scale();
					if (scale < 0 && scale > POOR_SCALE_MIN) {
						value = value.setScale(0, BigDecimal.ROUND_UNNECESSARY);
					}
					return value;
				} catch (NumberFormatException e) {
					throw new JsonSyntaxException(e);
				}
			}

			@Override
			public void write(JsonWriter out, BigDecimal value) throws IOException {
				out.value(value);
			}
		};

		CROSS_DOMAIN_ALLOWED_METHOD = new String[] { RequestMethod.GET.name(), RequestMethod.POST.name() //
				, RequestMethod.PUT.name(), RequestMethod.DELETE.name() //
				, RequestMethod.HEAD.name(), RequestMethod.PATCH.name(), RequestMethod.TRACE.name() };

	}

}
