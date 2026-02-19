<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
const rewards = ref([])
const totalStudyMinutes = ref(0)
const spentRewardMinutes = ref(0)
const loading = ref(true)
const error = ref('')
const newName = ref('')
const newCost = ref(30)
const adding = ref(false)

const availableMinutes = computed(() =>
  Math.max(0, totalStudyMinutes.value - spentRewardMinutes.value)
)

function formatMinutes(m) {
  if (m < 60) return `${Math.round(m)} 分钟`
  const h = Math.floor(m / 60)
  const min = Math.round(m % 60)
  return min ? `${h} 小时 ${min} 分钟` : `${h} 小时`
}

async function loadRewards() {
  const uid = authStore.user?.id
  if (!uid) return
  const { data } = await supabase.from('rewards').select('*').eq('user_id', uid).order('created_at', { ascending: false })
  rewards.value = data || []
}

async function loadSums() {
  const uid = authStore.user?.id
  if (!uid) return
  const [sessions, redemptions] = await Promise.all([
    supabase.from('study_sessions').select('duration_minutes').eq('user_id', uid),
    supabase.from('reward_redemptions').select('cost_minutes').eq('user_id', uid)
  ])
  totalStudyMinutes.value = (sessions.data || []).reduce(
    (s, r) => s + (r.duration_minutes || 0),
    0
  )
  spentRewardMinutes.value = (redemptions.data || []).reduce(
    (s, r) => s + (r.cost_minutes || 0),
    0
  )
}

async function addReward() {
  error.value = ''
  const name = (newName.value || '').trim()
  const cost = Number(newCost.value)
  if (!name || cost <= 0) {
    error.value = '请填写礼物名称和所需学习分钟数'
    return
  }
  adding.value = true
  const uid = authStore.user?.id
  if (!uid) {
    adding.value = false
    return
  }
  const { error: e } = await supabase.from('rewards').insert({
    user_id: uid,
    name,
    cost_study_minutes: cost
  })
  adding.value = false
  if (e) {
    error.value = e.message || '添加失败'
    return
  }
  newName.value = ''
  newCost.value = 30
  await loadRewards()
}

async function redeem(reward) {
  if (availableMinutes.value < reward.cost_study_minutes) {
    error.value = '学习时间不足，无法兑换'
    return
  }
  error.value = ''
  const uid = authStore.user?.id
  if (!uid) return
  const { error: e } = await supabase.from('reward_redemptions').insert({
    user_id: uid,
    reward_id: reward.id,
    cost_minutes: reward.cost_study_minutes
  })
  if (e) {
    error.value = e.message || '兑换失败'
    return
  }
  await loadSums()
  await loadRewards()
}

async function removeReward(id) {
  const uid = authStore.user?.id
  if (!uid) return
  const { error: e } = await supabase.from('rewards').delete().eq('id', id).eq('user_id', uid)
  if (e) {
    error.value = e.code === '23503' ? '该礼物已有兑换记录，无法删除' : e.message
    return
  }
  await loadRewards()
}

onMounted(async () => {
  loading.value = true
  await loadSums()
  await loadRewards()
  loading.value = false
})
</script>

<template>
  <div class="store">
    <h1 class="page-title">
      礼物商店
    </h1>
    <p
      v-if="error"
      class="error-msg"
    >
      {{ error }}
    </p>
    <div
      v-if="loading"
      class="loading-state"
      role="status"
      aria-live="polite"
    >
      <span
        class="loading-state__spinner"
        aria-hidden="true"
      />
      <span class="loading-state__text">加载中…</span>
    </div>
    <template v-else>
      <div class="card balance-card">
        <h2 class="card-title">
          可用于兑换的学习时间
        </h2>
        <p class="balance-value">
          {{ formatMinutes(availableMinutes) }}
        </p>
      </div>
      <div class="card form-card">
        <h2 class="card-title">
          添加礼物
        </h2>
        <div class="form-row">
          <input
            v-model="newName"
            type="text"
            placeholder="礼物名称"
            class="input"
          >
          <input
            v-model.number="newCost"
            type="number"
            min="1"
            placeholder="所需分钟"
            class="input input-num"
          >
          <span class="unit">分钟</span>
          <button
            type="button"
            :disabled="adding"
            @click="addReward"
          >
            {{ adding ? '添加中…' : '添加' }}
          </button>
        </div>
      </div>
      <div class="card list-card">
        <h2 class="card-title">
          我的礼物列表
        </h2>
        <ul
          v-if="rewards.length"
          class="reward-list"
        >
          <li
            v-for="r in rewards"
            :key="r.id"
            class="reward-item"
          >
            <span class="reward-name">{{ r.name }}</span>
            <span class="reward-cost">{{ r.cost_study_minutes }} 分钟</span>
            <div class="reward-actions">
              <button
                type="button"
                class="secondary"
                :disabled="availableMinutes < r.cost_study_minutes"
                @click="redeem(r)"
              >
                兑换
              </button>
              <button
                type="button"
                class="btn-remove"
                @click="removeReward(r.id)"
              >
                删除
              </button>
            </div>
          </li>
        </ul>
        <p
          v-else
          class="empty"
        >
          暂无礼物，请先添加
        </p>
      </div>
    </template>
  </div>
</template>

<style scoped>
.store {
  max-width: 560px;
}
.balance-card {
  margin-bottom: var(--space-lg);
}
.balance-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--primary);
  margin: var(--space-sm) 0 0;
}
.card-title {
  font-size: 1rem;
  font-weight: 600;
  margin: 0;
  color: var(--text-muted);
}
.form-card {
  margin-bottom: var(--space-lg);
}
.form-row {
  display: flex;
  align-items: center;
  gap: var(--space-sm);
  flex-wrap: wrap;
}
.input-num {
  width: 90px;
}
@media (max-width: 768px) {
  .form-row {
    flex-direction: column;
    align-items: stretch;
  }
  .form-row .input,
  .form-row .input-num {
    width: 100%;
  }
  .form-row button {
    width: 100%;
  }
  .reward-item {
    flex-direction: column;
    align-items: flex-start;
    gap: var(--space-sm);
  }
  .reward-actions {
    width: 100%;
    justify-content: flex-end;
  }
}
.unit {
  color: var(--text-muted);
}
.reward-list {
  list-style: none;
  padding: 0;
  margin: 0;
}
.reward-item {
  display: flex;
  align-items: center;
  gap: var(--space-md);
  padding: var(--space-md) 0;
  border-bottom: 1px solid var(--border);
  flex-wrap: wrap;
}
.reward-item:last-child {
  border-bottom: none;
}
.reward-name {
  flex: 1;
  font-weight: 500;
}
.reward-cost {
  color: var(--text-muted);
  font-size: 0.9rem;
}
.reward-actions {
  display: flex;
  gap: var(--space-xs);
}
.btn-remove {
  background: transparent;
  color: var(--text-muted);
  border: 1px solid var(--border);
  font-size: 0.85rem;
}
.btn-remove:hover {
  color: var(--danger);
  border-color: var(--danger);
  background: transparent;
}
.empty {
  color: var(--text-muted);
  margin: 0;
}
</style>
