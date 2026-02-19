# 学豆 (StudyBean)

用学习/进步时间攒「豆子」、换娱乐和礼物奖励的 Web 应用。支持多设备登录与数据同步。

**[更新日志](CHANGELOG.md)** · [LICENSE](LICENSE)（MIT）

## 功能

- **学习计时**：开始/暂停/结束会话，记录学习或进步时长。
- **比例设置**：自定义「学习时间 : 可兑换娱乐时间」比例（如 0.5 表示 1 小时学习换 30 分钟娱乐）。
- **娱乐时间**：根据累计学习 × 比例得到可用娱乐时间；可手动记录「本次刷手机/娱乐」时长并扣减。
- **礼物商店**：自定义奖励项（名称 + 所需学习分钟），用累计学习时间兑换。
- **历史**：学习会话、娱乐使用、礼物兑换记录。
- **移动端适配**：小屏下底部导航、触控友好（按钮/输入框约 44px 最小高度）、安全区域适配；表单在窄屏下纵向排列。
- **设置确认**：在「设置」页修改比例或昵称后，点击「保存」会先弹出确认框，确认后才会写入，避免误触直接修改。

## 技术栈

- 前端：Vue 3（Composition API / setup）+ Vite
- 状态：Pinia
- 路由：Vue Router
- 后端/数据：Supabase（认证 + PostgreSQL + RLS）
- 部署：可部署到 Vercel / Netlify 等静态托管

## 本地运行

### 环境要求

- Node.js **20.19+ 或 22.12+**（Vite 7 与当前依赖要求）
- npm 或 pnpm

### 步骤

1. 克隆或进入项目目录后安装依赖：

   ```bash
   npm install
   ```

2. 配置 Supabase：
   - 在 [Supabase](https://supabase.com/dashboard) 创建项目。
   - 在 SQL Editor 中执行 [`supabase/schema.sql`](supabase/schema.sql) 创建表与 RLS。
   - 在 Authentication -> Providers 中启用 Email，并视需启用「Confirm email」等。

3. 复制环境变量并填入你的项目信息：

   ```bash
   cp .env.example .env
   ```

   编辑 `.env`：

   ```
   VITE_SUPABASE_URL=https://你的项目.supabase.co
   VITE_SUPABASE_ANON_KEY=你的 anon key
   ```

   Supabase 项目 URL 与 anon key 在：Project Settings -> API。

4. 启动开发服务器：

   ```bash
   npm run dev
   ```

   浏览器打开控制台显示的本地地址（如 `http://localhost:5173`）。

### 其他脚本

- `npm run build`：生产构建，输出到 `dist/`。
- `npm run preview`：预览生产构建。
- `npm run lint`：运行 ESLint（建议 Node 18+）。

## 环境变量说明

| 变量名 | 说明 |
|--------|------|
| `VITE_SUPABASE_URL` | Supabase 项目 URL |
| `VITE_SUPABASE_ANON_KEY` | Supabase 匿名（公开）密钥，用于浏览器端 |

不要将 `.env` 提交到版本库；生产部署时在 Vercel/Netlify 等平台配置同名环境变量。

## 页面与路由

| 路径 | 说明 |
|------|------|
| `/login` | 登录/注册（邮箱+密码） |
| `/` | 首页：学习计时、可用娱乐时间、可兑换学习时间、累计学习 |
| `/settings` | 设置：学习:娱乐 比例、昵称 |
| `/entertainment` | 娱乐时间：可用余额、记录本次使用 |
| `/store` | 礼物商店：添加礼物、兑换、删除 |
| `/history` | 历史：学习记录、娱乐使用、礼物兑换 |

## 兑换与比例规则

- **可用娱乐时间** = 累计学习时间 × 比例 − 已使用的娱乐时间（分钟）。
- **可用于兑换礼物的学习时间** = 累计学习时间 − 已用于礼物兑换的学习时间。
- 比例建议 0～2，例如 0.5 表示 1 小时学习换 30 分钟娱乐。

更多说明见 [docs/](docs/)。

## 部署

1. 执行 `npm run build`。
2. 将 `dist/` 部署到 Vercel、Netlify 等，并配置 `VITE_SUPABASE_URL`、`VITE_SUPABASE_ANON_KEY`。
3. 在 Supabase Dashboard -> Authentication -> URL Configuration 中把站点 URL 和重定向 URL 加入允许列表。
