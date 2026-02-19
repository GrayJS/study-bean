<script setup>
import { ref, onMounted, computed } from 'vue'
import { supabase } from '../lib/supabase'
import { useAuthStore } from '../stores/auth'
import StudyTimer from '../components/StudyTimer.vue'

const authStore = useAuthStore()
const profile = ref(null)
const totalStudyMinutes = ref(0)
const spentEntertainmentMinutes = ref(0)
const spentRewardMinutes = ref(0)
const loading = ref(true)
const error = ref('')

const ratio = computed(() => profile.value?.study_to_entertainment_ratio ?? 0.5)
const availableEntertainmentMinutes = computed(() => {
  const earned = totalStudyMinutes.value * ratio.value
  return Math.max(0, Math.floor(earned - spentEntertainmentMinutes.value))
})
const availableRewardMinutes = computed(() =>
  Math.max(0, totalStudyMinutes.value - spentRewardMinutes.value)
)

function formatMinutes(m) {
  if (m < 60) return `${Math.round(m)} 分钟`
  const h = Math.floor(m / 60)
  const min = Math.round(m % 60)
  return min ? `${h} 小时 ${min} 分钟` : `${h} 小时`
}

async function loadProfile() {
  const uid = authStore.user?.id
  if (!uid) return
  const { data, error: e } = await supabase
    .from('profiles')
    .select('*')
    .eq('user_id', uid)
    .single()
  if (!e) profile.value = data
}

async function loadSums() {
  const uid = authStore.user?.id
  if (!uid) return
  error.value = ''
  try {
    const [sessions, entertainment, redemptions] = await Promise.all([
      supabase.from('study_sessions').select('duration_minutes').eq('user_id', uid),
      supabase.from('entertainment_usage').select('minutes').eq('user_id', uid),
      supabase.from('reward_redemptions').select('cost_minutes').eq('user_id', uid)
    ])

    totalStudyMinutes.value = (sessions.data || []).reduce((s, r) => s + (r.duration_minutes || 0), 0)
    spentEntertainmentMinutes.value = (entertainment.data || []).reduce(
      (s, r) => s + (r.minutes || 0),
      0
    )
    spentRewardMinutes.value = (redemptions.data || []).reduce(
      (s, r) => s + (r.cost_minutes || 0),
      0
    )
  } catch (e) {
    error.value = e?.message || '加载数据失败'
  }
}

onMounted(async () => {
  loading.value = true
  await loadProfile()
  await loadSums()
  loading.value = false
})
</script>

<template>
  <div class="home">
    <h1 class="page-title">
      首页
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
      <section class="section">
        <StudyTimer @saved="loadSums" />
      </section>
      <section class="section cards">
        <div class="card balance-card">
          <h2 class="card-title">
            可用娱乐时间
          </h2>
          <p class="balance-value">
            {{ formatMinutes(availableEntertainmentMinutes) }}
          </p>
          <p class="card-hint">
            学习时间 × 比例 − 已使用
          </p>
        </div>
        <div class="card balance-card">
          <h2 class="card-title">
            可兑换礼物（学习时间）
          </h2>
          <p class="balance-value">
            {{ formatMinutes(availableRewardMinutes) }}
          </p>
          <p class="card-hint">
            累计学习 − 已兑换
          </p>
        </div>
      </section>
      <section class="section">
        <div class="card">
          <h2 class="card-title">
            累计学习时间
          </h2>
          <p class="balance-value">
            {{ formatMinutes(totalStudyMinutes) }}
          </p>
        </div>
      </section>
    </template>
  </div>
</template>

<style scoped>
.home {
  max-width: 720px;
  margin: 0 auto;
}
.section {
  margin-bottom: var(--space-xl);
}
.cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: var(--space-lg);
}
@media (max-width: 768px) {
  .home .section {
    margin-bottom: var(--space-lg);
  }
  .cards {
    grid-template-columns: 1fr;
    gap: var(--space-md);
  }
}
.balance-card .balance-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--primary);
  margin: var(--space-sm) 0;
}
.card-title {
  font-size: 1rem;
  font-weight: 600;
  margin: 0;
  color: var(--text-muted);
}
.card-hint {
  font-size: 0.85rem;
  color: var(--text-muted);
  margin: 0;
}
</style>
