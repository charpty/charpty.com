package com.charpty;

import com.charpty.config.ServiceConfig;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

/**
 * @author CaiBo
 * @version $Id$
 * @since 2017/8/17 下午4:07
 */
@Configuration
@Import({ AutoConfig.class, ServiceConfig.class })
public class Application {

	public static void main(String[] args) throws Exception {
		SpringApplication.run(Application.class, args);
	}
}
