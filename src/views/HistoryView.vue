<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
const sessions = ref([])
const entertainment = ref([])
const redemptions = ref([])
const loading = ref(true)
const error = ref('')
const tab = ref('sessions')

function formatDate(iso) {
  if (!iso) return '-'
  const d = new Date(iso)
  return d.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function formatMinutes(m) {
  if (m == null) return '-'
  if (m < 60) return `${Math.round(m)} 分钟`
  const h = Math.floor(m / 60)
  const min = Math.round(m % 60)
  return min ? `${h} 小时 ${min} 分钟` : `${h} 小时`
}

async function load() {
  const uid = authStore.user?.id
  if (!uid) return
  error.value = ''
  try {
    const [sRes, eRes, rRes] = await Promise.all([
      supabase
        .from('study_sessions')
        .select('*')
        .eq('user_id', uid)
        .order('created_at', { ascending: false })
        .limit(50),
      supabase
        .from('entertainment_usage')
        .select('*')
        .eq('user_id', uid)
        .order('created_at', { ascending: false })
        .limit(50),
      supabase
        .from('reward_redemptions')
        .select('*, rewards(name)')
        .eq('user_id', uid)
        .order('created_at', { ascending: false })
        .limit(50)
    ])
    sessions.value = sRes.data || []
    entertainment.value = eRes.data || []
    redemptions.value = rRes.data || []
  } catch (e) {
    error.value = e?.message || '加载失败'
  }
  loading.value = false
}

onMounted(load)
</script>

<template>
  <div class="history">
    <h1 class="page-title">历史</h1>
    <p v-if="error" class="error-msg">{{ error }}</p>
    <div v-if="loading" class="loading-state">加载中…</div>
    <template v-else>
      <div class="tabs">
        <button
          type="button"
          :class="['tab', { active: tab === 'sessions' }]"
          @click="tab = 'sessions'"
        >
          学习记录
        </button>
        <button
          type="button"
          :class="['tab', { active: tab === 'entertainment' }]"
          @click="tab = 'entertainment'"
        >
          娱乐使用
        </button>
        <button
          type="button"
          :class="['tab', { active: tab === 'redemptions' }]"
          @click="tab = 'redemptions'"
        >
          礼物兑换
        </button>
      </div>
      <div class="card list-card">
        <div v-if="tab === 'sessions'" class="list">
          <div v-if="!sessions.length" class="empty">暂无学习记录</div>
          <div
            v-for="s in sessions"
            :key="s.id"
            class="row"
          >
            <span class="date">{{ formatDate(s.ended_at) }}</span>
            <span class="value">{{ formatMinutes(s.duration_minutes) }}</span>
          </div>
        </div>
        <div v-else-if="tab === 'entertainment'" class="list">
          <div v-if="!entertainment.length" class="empty">暂无娱乐使用记录</div>
          <div v-for="e in entertainment" :key="e.id" class="row">
            <span class="date">{{ formatDate(e.created_at) }}</span>
            <span class="value">− {{ e.minutes }} 分钟</span>
          </div>
        </div>
        <div v-else class="list">
          <div v-if="!redemptions.length" class="empty">暂无兑换记录</div>
          <div v-for="r in redemptions" :key="r.id" class="row">
            <span class="date">{{ formatDate(r.created_at) }}</span>
            <span class="value">{{ r.rewards?.name || '礼物' }} − {{ r.cost_minutes }} 分钟</span>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<style scoped>
.history {
  max-width: 640px;
}
.tabs {
  display: flex;
  gap: var(--space-xs);
  margin-bottom: var(--space-lg);
}
.tab {
  padding: var(--space-sm) var(--space-md);
  background: var(--surface);
  color: var(--text-muted);
  border: 1px solid var(--border);
}
.tab.active {
  background: var(--primary-subtle);
  color: var(--primary);
  border-color: var(--primary);
}
.list {
  padding: 0;
}
.row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--space-md) 0;
  border-bottom: 1px solid var(--border);
}
.row:last-child {
  border-bottom: none;
}
.date {
  color: var(--text-muted);
  font-size: 0.9rem;
}
.value {
  font-weight: 500;
}
.empty {
  color: var(--text-muted);
  padding: var(--space-xl);
  text-align: center;
}
</style>
