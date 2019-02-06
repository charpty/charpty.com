package com.charpty.handlers;

import com.charpty.server.HTTPRequest;
import com.charpty.server.RequestHandler;

/**
 * @author charpty
 * @since 2017/12/24
 */
public class DailyWordHandler implements RequestHandler {

    private static final String DW_PATH = "/word/random";

    private final int mask = 31;
    private final String[] arr = new String[mask + 1];
    private int random = 6;

    public DailyWordHandler() {
        initWords();
    }

    @Override
    public String handle(HTTPRequest request) {
        String path = request.getPath();
        if (DW_PATH.equals(path)) {
            return random();
        }
        return null;
    }

    public String random() {
        // > 0
        return "\"" + arr[random++ >>> 1 & mask] + "\"";
    }

    public final void initWords() {
        arr[0] = "成功=目标，其他语句都是这行代码的注释";
        arr[1] = "争斗中最痛苦的不是失败，而是承认失败";
        arr[2] = "经得起多少诋毁，就担得起多少赞美";
        arr[3] = "现在觉得累正常，走下坡路才不累";
        arr[4] = "成长是和过去告别，成为一个更好的自己";
        arr[5] = "善良不是好事，你给了别人伤害你的资本";
        arr[6] = "有时一句话流泪，有时咬牙走了很长的路";
        arr[7] = "觉醒之际天才会破晓，破晓的不止是黎明";
        arr[8] = "只想心境不要再粗糙，这是我的最大愿望";
        arr[9] = "想知道周围的黑暗,就得留意远处的微光";
        arr[10] = "青春是培养习惯希望及信仰的一段时光";
        arr[11] = "想法十分钱一打，无价的是能够实现的人";
        arr[12] = "微笑拥抱每一天，做向日葵般温暖的女子";
        arr[13] = "爱超越生命长度、心灵宽度、灵魂的深度";
        arr[14] = "痛苦是性格催化剂使强者更强，弱者更弱";
        arr[15] = "成功的关键在于相信自己有成功的能力";
        arr[16] = "命运掌握在自己手里，好坏由自己去创造";
        arr[17] = "不让生活留下遗憾，抓住改变生活的机会";
        arr[18] = "天道酬勤，但付出了不一定得到回报";
        arr[19] = "生活是个势利眼，你得直起腰板做人";
        arr[20] = "当时间的主人，命运的主宰，灵魂的舵手";
        arr[21] = "你要做多大的事情，就该承受多大的压力";
        arr[22] = "生活对于智者永远是一首昂扬的歌";
        arr[23] = "路一旦开始便不能终止，才是真正的坚持";
        arr[24] = "不要在别人的故事里留着自己的泪";
        // padding
        arr[25] = "不要在别人的故事里留着自己的泪";
        arr[26] = "路一旦开始便不能终止，才是真正的坚持";
        arr[27] = "生活对于智者永远是一首昂扬的歌";
        arr[28] = "你要做多大的事情，就该承受多大的压力";
        arr[29] = "当时间的主人，命运的主宰，灵魂的舵手";
        arr[30] = "不让生活留下遗憾，抓住改变生活的机会";
        arr[31] = "天道酬勤，但付出了不一定得到回报";
    }

}
