<script setup>
import { ref, computed, onUnmounted } from 'vue'
import { supabase } from '../lib/supabase'
import { useAuthStore } from '../stores/auth'

const emit = defineEmits(['saved'])
const authStore = useAuthStore()

const running = ref(false)
const startTime = ref(null)
const elapsedSeconds = ref(0)
const saving = ref(false)
let ticker = null

const displayTime = computed(() => {
  const s = Math.floor(elapsedSeconds.value)
  const m = Math.floor(s / 60)
  const h = Math.floor(m / 60)
  const mm = m % 60
  const ss = s % 60
  if (h > 0) return `${h}:${String(mm).padStart(2, '0')}:${String(ss).padStart(2, '0')}`
  return `${mm}:${String(ss).padStart(2, '0')}`
})

function start() {
  if (running.value) return
  running.value = true
  startTime.value = startTime.value || Date.now()
  ticker = setInterval(() => {
    elapsedSeconds.value = (Date.now() - startTime.value) / 1000
  }, 1000)
}

function pause() {
  if (!running.value) return
  running.value = false
  if (ticker) clearInterval(ticker)
  ticker = null
}

async function finish() {
  if (saving.value) return
  const durationMinutes = elapsedSeconds.value / 60
  if (durationMinutes < 0.5) {
    return
  }
  saving.value = true
  const uid = authStore.user?.id
  if (!uid) {
    saving.value = false
    return
  }
  const endedAt = new Date().toISOString()
  const startedAt = startTime.value
    ? new Date(startTime.value).toISOString()
    : new Date(Date.now() - elapsedSeconds.value * 1000).toISOString()
  const { error } = await supabase.from('study_sessions').insert({
    user_id: uid,
    started_at: startedAt,
    ended_at: endedAt,
    duration_minutes: Math.round(durationMinutes * 10) / 10
  })
  saving.value = false
  if (error) {
    console.error('Save study session error:', error)
    return
  }
  running.value = false
  if (ticker) clearInterval(ticker)
  ticker = null
  startTime.value = null
  elapsedSeconds.value = 0
  emit('saved')
}

onUnmounted(() => {
  if (ticker) clearInterval(ticker)
})
</script>

<template>
  <div class="timer card">
    <h2 class="card-title">
      学习计时
    </h2>
    <p class="time-display">
      {{ displayTime }}
    </p>
    <div class="actions">
      <button
        v-if="!running"
        type="button"
        @click="start"
      >
        开始
      </button>
      <template v-else>
        <button
          type="button"
          @click="pause"
        >
          暂停
        </button>
        <button
          type="button"
          :disabled="saving || elapsedSeconds < 30"
          @click="finish"
        >
          {{ saving ? '保存中…' : '结束并保存' }}
        </button>
      </template>
    </div>
  </div>
</template>

<style scoped>
.timer {
  text-align: center;
}
.time-display {
  font-size: 2.5rem;
  font-weight: 700;
  margin: var(--space-md) 0;
  font-variant-numeric: tabular-nums;
}
.actions {
  display: flex;
  gap: var(--space-sm);
  justify-content: center;
  flex-wrap: wrap;
}
@media (max-width: 768px) {
  .time-display {
    font-size: 2.2rem;
  }
  .actions button {
    min-width: 110px;
    padding: var(--btn-padding-y, 0.65em) var(--btn-padding-x, 1.25em);
  }
}
</style>
