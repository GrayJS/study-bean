<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
const ratio = ref(0.5)
const displayName = ref('')
const loading = ref(true)
const saving = ref(false)
const error = ref('')
const message = ref('')

async function load() {
  const uid = authStore.user?.id
  if (!uid) return
  const { data, error: e } = await supabase
    .from('profiles')
    .select('study_to_entertainment_ratio, display_name')
    .eq('user_id', uid)
    .single()
  if (!e && data) {
    ratio.value = Number(data.study_to_entertainment_ratio) ?? 0.5
    displayName.value = data.display_name || ''
  }
  loading.value = false
}

async function save() {
  error.value = ''
  message.value = ''
  const r = Number(ratio.value)
  if (r < 0 || r > 2) {
    error.value = '比例建议在 0～2 之间（例如 0.5 表示 1 小时学习换 30 分钟娱乐）'
    return
  }
  saving.value = true
  const uid = authStore.user?.id
  if (!uid) {
    saving.value = false
    return
  }
  const { error: e } = await supabase
    .from('profiles')
    .upsert(
      {
        user_id: uid,
        study_to_entertainment_ratio: r,
        display_name: displayName.value || null,
        updated_at: new Date().toISOString()
      },
      { onConflict: 'user_id' }
    )
  saving.value = false
  if (e) {
    error.value = e.message || '保存失败'
    return
  }
  message.value = '已保存'
}

onMounted(load)
</script>

<template>
  <div class="settings">
    <h1 class="page-title">设置</h1>
    <div v-if="loading" class="loading-state">加载中…</div>
    <div v-else class="card form-card">
      <p class="hint">学习:娱乐 比例。例如 0.5 表示 1 小时学习可兑换 30 分钟娱乐时间。</p>
      <label class="label">
        比例（0～2）
        <input v-model.number="ratio" type="number" min="0" max="2" step="0.1" class="input" />
      </label>
      <label class="label">
        昵称（可选）
        <input v-model="displayName" type="text" placeholder="显示名称" class="input" />
      </label>
      <p v-if="error" class="error-msg">{{ error }}</p>
      <p v-if="message" class="success-msg">{{ message }}</p>
      <button type="button" class="btn-save" :disabled="saving" @click="save">
        {{ saving ? '保存中…' : '保存' }}
      </button>
    </div>
  </div>
</template>

<style scoped>
.settings {
  max-width: 480px;
}
.form-card {
  display: flex;
  flex-direction: column;
  gap: var(--space-md);
}
.hint {
  color: var(--text-muted);
  font-size: 0.9rem;
  margin: 0 0 var(--space-sm);
}
.label {
  display: flex;
  flex-direction: column;
  gap: var(--space-xs);
  font-weight: 500;
}
.btn-save {
  align-self: flex-start;
}
.success-msg {
  color: var(--success);
  font-size: 0.9rem;
  margin: 0;
}
</style>
