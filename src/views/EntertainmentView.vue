<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
const profile = ref(null)
const totalStudyMinutes = ref(0)
const spentEntertainmentMinutes = ref(0)
const minutesToUse = ref(15)
const loading = ref(true)
const submitting = ref(false)
const error = ref('')

const ratio = computed(() => profile.value?.study_to_entertainment_ratio ?? 0.5)
const availableMinutes = computed(() => {
  const earned = totalStudyMinutes.value * ratio.value
  return Math.max(0, Math.floor(earned - spentEntertainmentMinutes.value))
})

function formatMinutes(m) {
  if (m < 60) return `${Math.round(m)} 分钟`
  const h = Math.floor(m / 60)
  const min = Math.round(m % 60)
  return min ? `${h} 小时 ${min} 分钟` : `${h} 小时`
}

async function loadProfile() {
  const uid = authStore.user?.id
  if (!uid) return
  const { data } = await supabase.from('profiles').select('*').eq('user_id', uid).single()
  if (data) profile.value = data
}

async function loadSums() {
  const uid = authStore.user?.id
  if (!uid) return
  const [sessions, usage] = await Promise.all([
    supabase.from('study_sessions').select('duration_minutes').eq('user_id', uid),
    supabase.from('entertainment_usage').select('minutes').eq('user_id', uid)
  ])
  totalStudyMinutes.value = (sessions.data || []).reduce(
    (s, r) => s + (r.duration_minutes || 0),
    0
  )
  spentEntertainmentMinutes.value = (usage.data || []).reduce((s, r) => s + (r.minutes || 0), 0)
}

async function submitUsage() {
  error.value = ''
  const min = Number(minutesToUse.value)
  if (min <= 0 || min > availableMinutes.value) {
    error.value = '请输入有效分钟数，且不超过可用娱乐时间'
    return
  }
  submitting.value = true
  const uid = authStore.user?.id
  if (!uid) {
    submitting.value = false
    return
  }
  const { error: e } = await supabase.from('entertainment_usage').insert({
    user_id: uid,
    minutes: min
  })
  submitting.value = false
  if (e) {
    error.value = e.message || '记录失败'
    return
  }
  await loadSums()
  minutesToUse.value = 15
}

onMounted(async () => {
  loading.value = true
  await loadProfile()
  await loadSums()
  loading.value = false
})
</script>

<template>
  <div class="entertainment">
    <h1 class="page-title">
      娱乐时间
    </h1>
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
          可用娱乐时间
        </h2>
        <p class="balance-value">
          {{ formatMinutes(availableMinutes) }}
        </p>
      </div>
      <div class="card form-card">
        <h2 class="card-title">
          记录本次使用
        </h2>
        <p class="hint">
          刷手机、看剧等消耗的娱乐时间（分钟）
        </p>
        <div class="form-row">
          <input
            v-model.number="minutesToUse"
            type="number"
            min="1"
            :max="availableMinutes"
            class="input"
          >
          <span class="unit">分钟</span>
          <button
            type="button"
            :disabled="submitting || availableMinutes < 1"
            @click="submitUsage"
          >
            {{ submitting ? '提交中…' : '确认扣除' }}
          </button>
        </div>
        <p
          v-if="error"
          class="error-msg"
        >
          {{ error }}
        </p>
      </div>
    </template>
  </div>
</template>

<style scoped>
.entertainment {
  max-width: 480px;
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
.form-card .card-title {
  margin-bottom: var(--space-sm);
}
.hint {
  color: var(--text-muted);
  font-size: 0.9rem;
  margin: 0 0 var(--space-md);
}
.form-row {
  display: flex;
  align-items: center;
  gap: var(--space-sm);
  flex-wrap: wrap;
}
.form-row .input {
  width: 100px;
}
@media (max-width: 768px) {
  .form-row {
    flex-direction: column;
    align-items: stretch;
  }
  .form-row .input {
    width: 100%;
  }
  .form-row button {
    width: 100%;
  }
}
.unit {
  color: var(--text-muted);
}
</style>
