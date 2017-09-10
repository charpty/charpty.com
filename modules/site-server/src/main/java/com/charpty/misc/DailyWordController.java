package com.charpty.misc;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;
import javax.annotation.PostConstruct;
import com.tomato.util.ClassUtil;
import com.tomato.util.NullUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/9/10 下午2:47
 */
@RestController
@RequestMapping
public class DailyWordController {

	private static final Logger LOGGER = LoggerFactory.getLogger(DailyWordController.class);

	private final Map<Integer, String> holder = new HashMap<>(512);
	private final int maxLines = 500;
	private final String DEFAULT_FIRST_WORD = "成功=目标，其他语句都是这行代码的注释";

	@PostConstruct
	public void init() throws IOException {
		InputStream stream = ClassUtil.getResourceAsStream("/misc/SimpleDailyWord.md");
		InputStreamReader isr = new InputStreamReader(stream);
		BufferedReader br = new BufferedReader(isr);
		String line;
		int count = 1;
		while ((line = br.readLine()) != null && count < maxLines) {
			if (!line.startsWith("#")) {
				holder.put(count++, line);
			}
		}
		// 这句话选中等记录扩大一倍D:)
		holder.put(0, DEFAULT_FIRST_WORD);
		LOGGER.info("共计加载每日一言数量: {}", holder.size());
	}

	@RequestMapping("/word/random")
	public String getRandomWord() {
		int size = holder.size();
		int key = ThreadLocalRandom.current().nextInt(0, size + 1);
		String result = holder.get(key);
		if (NullUtil.isNull(result)) {
			result = DEFAULT_FIRST_WORD;
		}
		return result;
	}

}
