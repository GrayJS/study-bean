<script setup>
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const navItems = [
  { path: '/', label: '首页' },
  { path: '/entertainment', label: '娱乐时间' },
  { path: '/store', label: '商店' },
  { path: '/history', label: '历史' },
  { path: '/settings', label: '设置' }
]

async function handleSignOut() {
  try {
    await authStore.signOut()
    router.push({ name: 'Login' })
  } catch (e) {
    console.error('Sign out error:', e)
  }
}
</script>

<template>
  <nav class="nav">
    <router-link to="/" class="brand">学豆</router-link>
    <div class="links">
      <router-link
        v-for="item in navItems"
        :key="item.path"
        :to="item.path"
        active-class="active"
        class="link"
      >
        {{ item.label }}
      </router-link>
      <button type="button" class="btn-logout" @click="handleSignOut">退出</button>
    </div>
  </nav>
</template>

<style scoped>
.nav {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--space-md) var(--space-lg);
  background: var(--surface);
  border-bottom: 1px solid var(--border);
}
.brand {
  font-weight: 700;
  font-size: 1.25rem;
  color: var(--text);
  text-decoration: none;
}
.links {
  display: flex;
  align-items: center;
  gap: var(--space-sm);
}
.link {
  padding: var(--space-xs) var(--space-sm);
  color: var(--text-muted);
  text-decoration: none;
  border-radius: var(--radius);
}
.link:hover,
.link.active {
  color: var(--primary);
  background: var(--primary-subtle);
}
.btn-logout {
  margin-left: var(--space-sm);
  padding: var(--space-xs) var(--space-sm);
  font-size: 0.9rem;
  color: var(--text-muted);
  background: transparent;
  border: 1px solid var(--border);
  border-radius: var(--radius);
  cursor: pointer;
}
.btn-logout:hover {
  color: var(--danger);
  border-color: var(--danger);
}
</style>
