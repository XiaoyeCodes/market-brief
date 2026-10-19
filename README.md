# Market Brief · 金融早报

围绕**美股、A股/港股、加密市场**的金融资讯网站，辅以宏观政策与机构研究。基于 [AIHOT](https://github.com/KKKKhazix/AIHOT) 的开源引擎定制，保留上游 MIT 许可证与版权声明。

## 内容范围

- 美股：上市公司财报、业绩指引、并购、回购、资本支出和市场动态。
- A股/港股：上市公司公告、IPO、产业供需、互联互通和交易规则。
- 加密市场：BTC、ETH、数字资产 ETF、稳定币、托管、安全事件和监管进展。
- 宏观与研究：央行、通胀、就业、财政及有数据支持的机构观点。

摘要保留关键金额、币种、日期、实际/预期/前值和事件阶段；有内容的栏目才进入日报。过滤无实质进展的营销、币圈喊单与重复转述。站内默认只展示摘要和原文链接。

## 当前状态

金融品牌、分类、标签、主题和筛选提示词已配置。本机已运行网站并导入10条人工核对的预览内容，**预览数据库和私人配置不随源码上传**。自动采集和模型处理尚未在本机启用，需要自行配置模型 API。

精选仍沿用框架默认门槛，尚未经过金融语料校准。日报按北京时间08:00截稿；刚收录的内容立即进入列表，按真实收录与发布时间进入对应后续日报。

## 初始信源

| 信源 | 接入方式 | 范围 |
|---|---|---|
| 美联储 | 官方 RSS | 货币政策、监管公告 |
| 美国 SEC | 官方 RSS | 证券监管 |
| CNBC | RSS | 美股与全球财经 |
| 港交所 | 官方 RSS | 港股及交易所公告 |
| CoinDesk | RSS | 加密市场 |
| Cointelegraph | RSS | 加密市场 |
| 财联社 | 人工核对后导入 | A股/港股、早报 |

RSS地址已在本机实际读取验证。财联社当前配置为外部导入源，尚未接入自动抓取。信源定义在 [`industry/sources.json`](industry/sources.json)，后续可在后台管理。

## 首次部署

需要 Node.js 24.11 或更高版本，以及 Docker Compose；不用 Docker 时需要 PostgreSQL 16/17，详见[部署文档](docs/deploy.md)。

```sh
git clone https://github.com/XiaoyeCodes/market-brief.git
cd market-brief
node scripts/init-env.ts
```

脚本会在本机生成`.env`和随机管理员密码。启动前编辑`.env`：

1. 设置站点地址`SITE_URL`。
2. 准备启用自动筛选时，填写自己的`LLM_BASE_URL`、`LLM_API_KEY`、`LLM_MODEL`。更换服务商时一并检查`LLM_EXTRA_JSON`是否适用。
3. 配置与验证期间保持`COLLECT_ENABLED=false`、`MODEL_CALLS_ENABLED=false`，通知与外部提交开关也保持关闭。确认信源与模型结果后再启用自动处理。

```sh
docker compose up -d --build
```

打开 <http://localhost:3000>，后台入口为`/admin/login`。首次启动会迁移数据库并导入金融信源。源码上传不等于网站已部署到云端。

### 当前电脑的本地启动脚本

[`site/local/`](site/local/)中的Windows脚本用于本机已经初始化的独立Node/PostgreSQL环境，不是首次安装程序。运行方式与检查记录见[本地说明](site/local/README.md)。数据库、运行时、日志、密码及缓存均存放在Git忽略的`.data/`或`.env`中。

## 开发与检查

```sh
npm ci
npm run typecheck
npm run build -w @aihot/web
node --test apps/web/tests/*.test.ts
```

后端测试必须将`DATABASE_URL`指向名称以`_test`或`_ci`结尾的独立测试数据库，再运行`npm test`。站点启动后可运行`node scripts/smoke.ts --base http://localhost:3000`。

本机类型检查、生产构建和30项冒烟检查通过；金融配置涉及的后端回归与元数据测试已核对。完整回归仍有Windows信号、备份、模块模拟及WebKit长列表返回相关失败，未宣称全部通过，详见[检查记录](site/local/README.md#已做的检查)。

## 文档与定制

- [行业配置](docs/customize.md)：站名、分类、提示词与品牌。
- [信源接入](docs/sources.md)：RSS、网页、JSON及外部推送。
- [精选与校准](docs/selection.md)：评分、门槛和样本评测。
- [部署](docs/deploy.md)：环境变量、Docker和独立进程。
- [架构](docs/architecture.md)：采集、发布、归组与扩展模块。

使用规则和隐私页仍为上游模板，正式对外运营前应按实际情况完成。原文版权归各来源所有。

## 开源来源

本项目定制自[KKKKhazix/AIHOT](https://github.com/KKKKhazix/AIHOT)，保留上游提交历史与[MIT许可证](LICENSE)。感谢原作者数字生命卡兹克及上游贡献者。
