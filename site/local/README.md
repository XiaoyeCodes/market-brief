# 金融早报本地版

范围：美股、A股/港股、加密市场，辅以宏观政策和机构研究。站内保留原文链接，详细摘要保留关键金额、币种、日期和事件阶段。栏目有内容才显示。

这些脚本用于当前电脑已经初始化的独立Node/PostgreSQL环境，不包含首次安装程序、运行时或私人数据库。新电脑请先按仓库根目录README或`docs/deploy.md`完成部署。

启动：在仓库根目录运行 `powershell -ExecutionPolicy Bypass -File site/local/start.ps1`，然后打开 http://localhost:3000 。停止用同目录 `stop.ps1`。当前只绑定本机，无系统服务、开机自启或云端部署。

后台：http://localhost:3000/admin/login 。管理员密码只保存在本机 `.data/admin-access.txt`；配置和数据库凭据在被 Git 忽略的 `.env`，不要上传。

## 当前运行方式

这是人工核对内容的本地预览。后台自动采集和模型调用关闭，也未启动 worker；未配置模型 API，因此还不能持续自动筛选、归组或生成新的金融早报。页面不会在访问时调用模型。已验证的 RSS 为美联储、SEC、CNBC、港交所、CoinDesk、Cointelegraph；财联社通过人工核对导入。

## 配置自动处理

1. 在本地 `.env` 填写自己的 OpenAI 兼容接口 `LLM_BASE_URL`、`LLM_API_KEY`、`LLM_MODEL`。不用把密钥发到聊天。
2. 查看 `docs/selection.md`，以金融样本核对分类、摘要和精选门槛。当前保留框架默认门槛，尚未做金融语料校准。
3. 在后台试抓与检查结果后，设置 `COLLECT_ENABLED=true`、`MODEL_CALLS_ENABLED=true`，再按 `docs/deploy.md` 启动 worker。外部模型可能按调用量计费。

日报采用框架的北京时间08:00截稿规则，展示前一个统计时段的精选。刚导入的内容会立即进入首页与全部动态，进入下一份日报；不倒填已发布的时间。周报、月报同样依赖实际处理的数据。

运行日志：`.data/api.*.log`、`.data/web.*.log`；独立数据库端口55437。使用规则和隐私页仍为上游模板，正式对外部署前需按实际运营情况完成。

原项目：https://github.com/KKKKhazix/AIHOT 。原有新闻邮件任务不在本项目中，未修改。

## 已做的检查

- 类型检查、生产构建、30项页面和接口冒烟检查通过；已在浏览器验证首页、美股筛选、详情及原文链接。
- 金融配置涉及的14个后端测试文件共81项，修正旧行业样例后通过；页面元数据10项通过。
- 浏览器回归仍有WebKit长列表进入详情后返回的断言失败。完整后端测试还遇到Windows信号、备份、模块模拟退出，以及测试数据库因进程ID复用重名的问题，未宣称全量通过。
- 日志在`.data/finance-tests*.log`、`.data/web-tests-v3.log`、`.data/backend-tests.log`。本次未为这些兼容性问题修改共享引擎。
