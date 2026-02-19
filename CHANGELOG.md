# 更新日志

所有对本项目的 notable 变更都会记录在此。格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

## [Unreleased]

（暂无未发布变更）

---

## [0.1.0] - 2025-02-18

### 新增

- **应用名称**：学豆 (StudyBean)
- **学习计时**：首页学习计时器，支持开始 / 暂停 / 结束并保存会话到 Supabase
- **首页仪表盘**：展示累计学习时间、可用娱乐时间、可兑换礼物的学习时间
- **设置页**：学习:娱乐 比例（0～2）、昵称，写入 `profiles`
- **娱乐时间页**：展示可用娱乐时间，支持记录「本次使用 X 分钟」并扣减
- **礼物商店**：自定义礼物（名称 + 所需学习分钟）、兑换、删除（已有兑换记录的礼物不可删）
- **历史页**：学习记录、娱乐使用、礼物兑换三个 Tab 列表
- **认证**：邮箱 + 密码登录 / 注册，Pinia 状态与路由守卫
- **多设备同步**：基于 Supabase 的账号与数据同步
- **Supabase 数据与 RLS**：`profiles`、`study_sessions`、`entertainment_usage`、`rewards`、`reward_redemptions` 及行级安全策略
- **文档**：README（运行、环境变量、路由说明）、docs/data-model.md、docs/future.md
- **更新日志**：本文件 CHANGELOG.md

### 技术栈

- Vue 3 (Composition API) + Vite、Pinia、Vue Router、Supabase JS Client
- 全局样式：CSS 变量，支持浅色 / 深色
- ESLint 配置与 `npm run lint`

[Unreleased]: https://github.com/your-username/study-bean/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/your-username/study-bean/releases/tag/v0.1.0
