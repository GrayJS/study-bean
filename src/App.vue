<script setup>
import { RouterView } from 'vue-router'
import AppNav from './components/AppNav.vue'
</script>

<template>
  <div class="app">
    <AppNav v-if="$route.meta.requiresAuth" />
    <main class="main">
      <RouterView />
    </main>
  </div>
</template>

<style scoped>
.app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}
.main {
  flex: 1;
  padding: var(--space-lg);
  padding-left: max(var(--space-lg), env(safe-area-inset-left));
  padding-right: max(var(--space-lg), env(safe-area-inset-right));
  /* 移动端为底部导航留出空间，避免内容被遮挡 */
  padding-bottom: max(var(--space-lg), env(safe-area-inset-bottom));
}

@media (max-width: 768px) {
  .main {
    padding: var(--space-md);
    padding-bottom: calc(56px + max(var(--space-md), env(safe-area-inset-bottom)));
  }
}
</style>
