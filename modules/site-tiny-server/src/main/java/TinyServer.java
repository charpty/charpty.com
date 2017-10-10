import boot.BootOption;
import boot.BootOptions;
import boot.BootStrap;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:00
 */
public class TinyServer {

	public static void main(String[] args) {
		BootOption bootOption = BootOptions.getBootOption(args);
		BootStrap.aeMain(bootOption);
	}
}
