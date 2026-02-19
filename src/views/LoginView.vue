<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const isSignUp = ref(false)
const email = ref('')
const password = ref('')
const error = ref('')
const loading = ref(false)

const submitLabel = computed(() => (isSignUp.value ? '注册' : '登录'))

async function submit() {
  error.value = ''
  if (!email.value || !password.value) {
    error.value = '请填写邮箱和密码'
    return
  }
  if (password.value.length < 6) {
    error.value = '密码至少 6 位'
    return
  }
  loading.value = true
  try {
    if (isSignUp.value) {
      await authStore.signUp(email.value, password.value)
      error.value = ''
      router.push(route.query.redirect || '/')
    } else {
      await authStore.signInWithPassword(email.value, password.value)
      error.value = ''
      router.push(route.query.redirect || '/')
    }
  } catch (e) {
    error.value = e?.message || '登录/注册失败，请重试'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-page">
    <div class="login-card card">
      <h1 class="title">
        学豆
      </h1>
      <p class="subtitle">
        StudyBean · 攒豆子，换娱乐和奖励
      </p>
      <form
        class="form"
        @submit.prevent="submit"
      >
        <input
          v-model="email"
          type="email"
          placeholder="邮箱"
          autocomplete="email"
          required
          class="input"
        >
        <input
          v-model="password"
          type="password"
          placeholder="密码（至少 6 位）"
          autocomplete="password"
          required
          class="input"
        >
        <p
          v-if="error"
          class="error-msg"
        >
          {{ error }}
        </p>
        <button
          type="submit"
          class="btn"
          :disabled="loading"
        >
          {{ loading ? '处理中…' : submitLabel }}
        </button>
      </form>
      <button
        type="button"
        class="toggle"
        @click="isSignUp = !isSignUp"
      >
        {{ isSignUp ? '已有账号？去登录' : '没有账号？去注册' }}
      </button>
    </div>
  </div>
</template>

<style scoped>
.login-page {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 80vh;
  padding: var(--space-lg);
}
.login-card {
  width: 100%;
  max-width: 380px;
}
.title {
  font-size: 1.75rem;
  margin: 0 0 var(--space-xs);
}
.subtitle {
  color: var(--text-muted);
  margin: 0 0 var(--space-xl);
  font-size: 0.95rem;
}
.form {
  display: flex;
  flex-direction: column;
  gap: var(--space-md);
}
.input {
  width: 100%;
}
.btn {
  width: 100%;
  min-height: var(--btn-min-height, 48px);
  padding: var(--btn-padding-y, 0.65em) var(--btn-padding-x, 1.25em);
  margin-top: var(--space-sm);
}
.toggle {
  margin-top: var(--space-lg);
  background: transparent;
  color: var(--text-muted);
  font-size: 0.9rem;
  border: none;
  padding: 0;
}
.toggle:hover {
  color: var(--primary);
  background: transparent;
  text-decoration: underline;
}
</style>
