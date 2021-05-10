package cn.edu.nciae.onlinejudge.contest.api;

import cn.edu.nciae.onlinejudge.contest.vo.CompetitionDTO;
import cn.edu.nciae.onlinejudge.contest.vo.CompetitionParam;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

/**
 * @author zhanghonglin
 * @version 1.0
 * @date 2021/5/8 9:47
 */
public interface CompetitionServiceApi {

    /**
     * 根据参数查询竞赛列表
     * @param page
     * @param competitionParam
     * @return
     */
    IPage<CompetitionDTO> getCompetitionListPage(Page page, CompetitionParam competitionParam);

    /**
     * 根据id查找具体竞赛
     * @param competitionId
     * @return
     */
    CompetitionDTO getCompetitionVOById(Long competitionId);
}