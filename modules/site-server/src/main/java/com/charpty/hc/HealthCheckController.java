package com.charpty.hc;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author CaiBo
 * @version $Id$
 * @since 2017/8/17 下午4:21
 */
@RestController
@RequestMapping("/hc")
public class HealthCheckController {

	@RequestMapping(value = "/current/time", method = RequestMethod.GET)
	public long currentTime() {
		return System.currentTimeMillis();
	}

}
