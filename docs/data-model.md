# 数据表说明

本应用使用 Supabase（PostgreSQL），表结构在 `supabase/schema.sql` 中定义。

## 表结构

### profiles

用户扩展信息，与 `auth.users` 一对一。

| 字段 | 类型 | 说明 |
|------|------|------|
| user_id | uuid (PK, FK auth.users) | 用户 ID |
| display_name | text | 昵称（可选） |
| study_to_entertainment_ratio | numeric | 学习:娱乐 比例，默认 0.5 |
| created_at, updated_at | timestamptz | 创建/更新时间 |

新用户注册时通过 trigger 自动插入一条 profile。

### study_sessions

学习会话记录。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | uuid (PK) | 主键 |
| user_id | uuid (FK auth.users) | 用户 ID |
| started_at | timestamptz | 开始时间 |
| ended_at | timestamptz | 结束时间 |
| duration_minutes | numeric | 时长（分钟） |
| created_at | timestamptz | 创建时间 |

### entertainment_usage

娱乐时间使用记录（每次「使用娱乐时间」一条）。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | uuid (PK) | 主键 |
| user_id | uuid (FK auth.users) | 用户 ID |
| minutes | numeric | 本次使用分钟数 |
| created_at | timestamptz | 创建时间 |

### rewards

用户自定义礼物。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | uuid (PK) | 主键 |
| user_id | uuid (FK auth.users) | 用户 ID |
| name | text | 礼物名称 |
| cost_study_minutes | numeric | 所需学习分钟数 |
| created_at | timestamptz | 创建时间 |

### reward_redemptions

礼物兑换记录。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | uuid (PK) | 主键 |
| user_id | uuid (FK auth.users) | 用户 ID |
| reward_id | uuid (FK rewards) | 兑换的礼物 ID |
| cost_minutes | numeric | 扣减的学习分钟数 |
| created_at | timestamptz | 兑换时间 |

## 派生逻辑（前端计算）

- **累计学习时间** = `sum(study_sessions.duration_minutes)`
- **已用于娱乐时间** = `sum(entertainment_usage.minutes)`
- **已用于礼物兑换的学习时间** = `sum(reward_redemptions.cost_minutes)`
- **可用娱乐时间** = 累计学习时间 × profiles.study_to_entertainment_ratio − 已用于娱乐时间
- **可用于兑换礼物的学习时间** = 累计学习时间 − 已用于礼物兑换的学习时间

## RLS

所有表启用 RLS，策略为：仅允许 `auth.uid() = user_id` 的读写，保证用户只能操作自己的数据。
