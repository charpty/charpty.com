import java.nio.charset.Charset;
import com.google.common.hash.Hashing;

/**
 * 微信签名设置
 *
 * @author charpty
 * @since 2018/2/14
 */
public class WeixinJsapiSignTest {
	private static final Charset CHARSET = Charset.forName("UTF-8");

	public static void main(String[] args) throws Exception {
		String noncestr = "ABCDEFG";
		String js_ticket = "sM4AOVdWfPE4DxkXGEs8VO16Y_sL2XZ71o14bKcCSLVCZFdjE9sl5qF2JI6ZVsN71E0re2UN_5SejzjDby-bSQ";
		String timeStr = String.valueOf(System.currentTimeMillis());
		timeStr = timeStr.substring(0, timeStr.length() - 3);
		String timestamp = timeStr;
		String url = "https://charpty.com/article/redis-protocol-resp";

		System.out.println("timestamp=" + timestamp);
		System.out.println("noncestr=" + noncestr);

		StringBuilder sb = new StringBuilder(256);
		sb.append("jsapi_ticket=").append(js_ticket);
		sb.append("&noncestr=").append(noncestr);
		sb.append("&timestamp=").append(timestamp);
		sb.append("&url=").append(url);
		System.out.println("处理前: " + sb.toString());
		String sign = Hashing.sha1().hashString(sb.toString(), CHARSET).toString();
		System.out.println("处理后: " + sign);
	}

}
