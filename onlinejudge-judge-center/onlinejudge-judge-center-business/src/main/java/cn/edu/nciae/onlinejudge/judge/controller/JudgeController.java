package cn.edu.nciae.onlinejudge.judge.controller;

import cn.edu.nciae.onlinejudge.commons.business.BusinessStatus;
import cn.edu.nciae.onlinejudge.commons.dto.MessageDTO;
import cn.edu.nciae.onlinejudge.commons.dto.ResponseResult;
import cn.edu.nciae.onlinejudge.commons.utils.SnowflakeUtil;
import cn.edu.nciae.onlinejudge.content.api.ProblemServiceApi;
import cn.edu.nciae.onlinejudge.content.vo.ProblemDTO;
import cn.edu.nciae.onlinejudge.contest.api.CompetitionProblemServiceApi;
import cn.edu.nciae.onlinejudge.contest.domain.CompetitionProblem;
import cn.edu.nciae.onlinejudge.judge.api.CompileServiceApi;
import cn.edu.nciae.onlinejudge.judge.api.LanguagesServiceApi;
import cn.edu.nciae.onlinejudge.judge.api.RunServiceApi;
import cn.edu.nciae.onlinejudge.judge.api.SubmissionServiceApi;
import cn.edu.nciae.onlinejudge.judge.domain.Compile;
import cn.edu.nciae.onlinejudge.judge.domain.Languages;
import cn.edu.nciae.onlinejudge.judge.domain.Run;
import cn.edu.nciae.onlinejudge.judge.domain.Submission;
import cn.edu.nciae.onlinejudge.judge.message.provider.SubmissionProvider;
import cn.edu.nciae.onlinejudge.judge.vo.*;
import cn.edu.nciae.onlinejudge.user.api.UserInfoServiceApi;
import cn.edu.nciae.onlinejudge.user.domain.UserInfo;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.apache.dubbo.config.annotation.Reference;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.ArrayList;
import java.util.List;

/**
 * @author zhanghonglin
 * @version 1.0
 * @date 2021/4/21 17:23
 */
@RestController
@RequestMapping("/judge")
public class JudgeController {

    @Reference(version = "1.0.0",check = false)
    private LanguagesServiceApi languagesServiceApi;

    @Reference(version = "1.0.0",check = false)
    private CompileServiceApi compileServiceApi;

    @Reference(version = "1.0.0",check = false)
    private RunServiceApi runServiceApi;

    @Reference(version = "1.0.0",check = false)
    private ProblemServiceApi problemServiceApi;

    @Reference(version = "1.0.0",check = false)
    private UserInfoServiceApi userInfoServiceApi;

    @Reference(version = "1.0.0",check = false)
    private SubmissionServiceApi submissionServiceApi;

    @Reference(version = "1.0.0",check = false)
    private CompetitionProblemServiceApi competitionProblemServiceApi;

    @Resource
    private SubmissionProvider submissionProvider;

    /**
     * 评测机的心跳检测
     * @param heartBeatParam
     * @return
     */
    @PostMapping("/heartbeat")
    public MessageDTO<String> heartBeat(@RequestBody HeartBeatParam heartBeatParam){
        return MessageDTO.<String>builder()
                .data("success")
                .err(null)
                .build();
    }

    /**
     * 提交代码，返回submissionId
     * @param submissionParam
     * @return
     */
    @PostMapping("/submission")
    public ResponseResult<String> submission(@RequestBody SubmissionParam submissionParam) throws Exception {
        // 获取submissionId
        SnowflakeUtil snowflakeUtil = new SnowflakeUtil(1L,1L);
        // 构造submissionId
        Long submissionId = snowflakeUtil.nextId();
        // 获取认证信息
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        // 获取用户名
        String userName = authentication.getName();
        // 获取用户信息
        UserInfo userInfo = userInfoServiceApi.getByUserName(userName);
        // 获取题目信息
        ProblemDTO problemDTO = null;
        if(submissionParam.getContest_id() != null){
//            说明参数中的problemid是展示id
            CompetitionProblem competitionProblem = competitionProblemServiceApi.getByCompetitionIdAndDisplayId(submissionParam.getContest_id(), submissionParam.getProblem_id());
            problemDTO = problemServiceApi.getProblemVOByPid(competitionProblem.getProblemId());
        }else{
//            说明参数是正常的id
            problemDTO = problemServiceApi.getProblemVOByPid(submissionParam.getProblem_id());
        }
        // 获取编程语言名称
        String languageName = submissionParam.getLanguage();
        // 获取语言对象
        Languages language = languagesServiceApi.getLanguageByLanguageName(languageName, problemDTO.getIsSpj());
        // 获取编译参数
        Compile compile = compileServiceApi.getCompileById(language.getLanguageCompileId());
        // 获取运行参数
        Run run = runServiceApi.getRunById(language.getLanguageRunId());
        // 转换类型
        CompileVO compileVO = vo2Obj(compile);
        RunVO runVO = vo2Obj(run);
        // 最大内存(MB)
        Integer problemMemoryLimitMB = problemDTO.getProblemMemoryLimit();
        Integer problemMemoryLimitB = problemMemoryLimitMB*1024*1024;
        // 构造SubmissionVO
        JudgeVO judgeVO = JudgeVO.builder()
                                    .src(submissionParam.getCode())
                                    .language_config(LanguageConfig.builder().compile(compileVO).run(runVO).build())
                                    .max_cpu_time(problemDTO.getProblemTimeLimit())
                                    .max_memory(problemMemoryLimitB)
                                    .test_case_id(problemDTO.getProblemTestcaseId())
                                    .output(true)
                                    .build();
        // 异步创建submission并进行评测
        submissionProvider.createSubmission(SubmissionVO.builder()
                                            .judgeVO(judgeVO)
                                            .submissionId(submissionId)
                                            .userId(userInfo.getUserId())
                                            .contestId(submissionParam.getContest_id())
                                            .problemId(submissionParam.getProblem_id())// 如果有竞赛，则此id是展示id
                                            .languageId(language.getLanguageId())
                                            .build());
        return ResponseResult.<String>builder()
                            .data(submissionId.toString())
                            .code(BusinessStatus.OK.getCode())
                            .message("提交成功")
                            .build();
    }

    /**
     * 根据Id获取提交信息
     * @param submissionId
     * @return
     */
    @GetMapping("/submission/{submissionId}")
    public ResponseResult<Submission> getSubmission(@PathVariable("submissionId") Long submissionId){
        Submission submission = submissionServiceApi.getById(submissionId);
        return ResponseResult.<Submission>builder()
                    .code(BusinessStatus.OK.getCode())
                    .message("查询提交信息成功")
                    .data(submission)
                    .build();
    }

    /**
     * 查询submission列表
     * @param offset
     * @param limit
     * @param submissionKeyword
     * @return
     */
    @GetMapping("/submission")
    public ResponseResult<SubmissionListVO> getSubmissionList(@RequestParam("offset") Integer offset,
                                                  @RequestParam("limit") Integer limit,
                                                  SubmissionKeyword submissionKeyword){
//        设置分页
        Page page;
        if (submissionKeyword.getPage() != null){
            page = new Page<ProblemDTO>(submissionKeyword.getPage(), limit);
        } else {
            page = new Page<ProblemDTO>(1, limit);
        }
        // 如果仅仅查看本人的状态信息
        if(submissionKeyword.getMyself() != null && submissionKeyword.getMyself() == 1){
            // 获取认证信息
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            //获取用户名
            String userName = authentication.getName();
            //获取用户
            UserInfo userInfo = userInfoServiceApi.getByUserName(userName);
            //将用户id添加进去
            submissionKeyword.setUserId(userInfo.getUserId());
        }else{
//            查看全部人的状态信息
//            如果需要查看指定用户的信息，则先找到指定用户的id列表，模糊查询
            if(submissionKeyword.getUsername() != null && !submissionKeyword.getUsername().equals("")){
                List<UserInfo> userInfoList = userInfoServiceApi.getUserListByUserName(submissionKeyword.getUsername());
                List<Long> userIdList = null;
                if(userInfoList != null && userInfoList.size() != 0){
                    userIdList = new ArrayList<>();
                    for (UserInfo userInfo : userInfoList){
                        userIdList.add(userInfo.getUserId());
                    }
                }
                submissionKeyword.setUserList(userIdList);
            }
        }
//        如果竞赛id为空，则设置为0
        if(submissionKeyword.getContest_id() == null){
            submissionKeyword.setContest_id(0L);
        }
//        查找出来不带用户名
        IPage<SubmissionDTO> submissions = submissionServiceApi.getSubmissionListPage(page, submissionKeyword);
        for(SubmissionDTO submissionDTO : submissions.getRecords()){
            UserInfo userInfo = userInfoServiceApi.getByUserId(submissionDTO.getSubmissionUserId());
            submissionDTO.setUsername(userInfo.getUserName());
        }
        return ResponseResult.<SubmissionListVO>builder()
                .code(BusinessStatus.OK.getCode())
                .message("查询题目分页列表成功")
                .data(SubmissionListVO.builder()
                        .results(submissions.getRecords())
                        .total(submissions.getTotal())
                        .build())
                .build();
    }

    /**
     * 转换类型  compile ---> compileVO
     * @param compile
     * @return
     */
    private CompileVO vo2Obj(Compile compile){
        if(compile == null){
            return null;
        }else{
            return CompileVO.builder()
                    .src_name(compile.getSrc_name())
                    .exe_name(compile.getExe_name())
                    .max_cpu_time(compile.getMax_cpu_time())
                    .max_memory(compile.getMax_memory())
                    .max_real_time(compile.getMax_real_time())
                    .compile_command(compile.getCompile_command())
                    .env(compile.getEnv())
                    .build();
        }
    }

    /**
     * 转换类型   run ---> runVO
     * @param run
     * @return
     */
    private RunVO vo2Obj(Run run){
        if(run == null){
            return null;
        }else{
            String[] envList = run.getEnv().split(",");
            return RunVO.builder()
                    .command(run.getCommand())
                    .seccomp_rule(run.getSeccomp_rule())
                    .exe_name(run.getExe_name())
                    .env(envList)
                    .memory_limit_check_only(run.getMemory_limit_check_only())
                    .build();
        }
    }

}