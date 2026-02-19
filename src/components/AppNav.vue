<script setup>
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const navItems = [
  { path: '/', label: '首页', icon: 'home' },
  { path: '/entertainment', label: '娱乐时间', icon: 'entertainment' },
  { path: '/store', label: '商店', icon: 'store' },
  { path: '/history', label: '历史', icon: 'history' },
  { path: '/settings', label: '设置', icon: 'settings' }
]


/** 底部导航图标（24x24 轮廓，currentColor 继承文字色） */
const navIcons = {
  home: 'M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8h5z',
  entertainment:
    'M768 791.893333c-44.373333 0-85.333333-20.48-109.226667-54.613333l-20.48-27.306667c-10.24-13.653333-6.826667-37.546667 6.826667-47.786666 13.653333-10.24 37.546667-6.826667 47.786667 6.826666l20.48 27.306667c23.893333 34.133333 81.92 37.546667 109.226666 3.413333 13.653333-17.066667 20.48-34.133333 17.066667-54.613333l-34.133333-262.826667c-10.24-75.093333-75.093333-126.293333-150.186667-119.466666l-119.466667 13.653333h-44.373333l-119.466667-13.653333C296.96 256 232.106667 307.2 221.866667 382.293333l-34.133334 262.826667c-3.413333 20.48 3.413333 40.96 17.066667 54.613333 27.306667 30.72 81.92 30.72 109.226667-3.413333l40.96-51.2c27.306667-34.133333 68.266667-54.613333 109.226666-54.613333H546.133333c20.48 0 34.133333 13.653333 34.133334 34.133333s-13.653333 34.133333-34.133334 34.133333h-85.333333c-20.48 0-44.373333 10.24-54.613333 27.306667l-40.96 51.2c-27.306667 34.133333-68.266667 54.613333-109.226667 54.613333-40.96 0-78.506667-17.066667-102.4-47.786666-27.306667-30.72-37.546667-68.266667-34.133333-109.226667l34.133333-262.826667c10.24-105.813333 112.64-187.733333 221.866667-174.08l119.466666 13.653334h30.72l122.88-13.653334c109.226667-13.653333 211.626667 68.266667 225.28 177.493334l34.133334 262.826666c3.413333 40.96-6.826667 78.506667-34.133334 109.226667-27.306667 27.306667-64.853333 44.373333-105.813333 44.373333z m-211.626667-368.64c-13.653333 13.653333-13.653333 34.133333 0 47.786667 13.653333 13.653333 34.133333 13.653333 47.786667 0 13.653333-13.653333 13.653333-34.133333 0-47.786667-13.653333-13.653333-34.133333-13.653333-47.786667 0z m71.68-64.853333c-13.653333 13.653333-13.653333 34.133333 0 47.786667 13.653333 13.653333 34.133333 13.653333 47.786667 0 13.653333-13.653333 13.653333-34.133333 0-47.786667-13.653333-13.653333-34.133333-13.653333-47.786667 0z m64.853334 64.853333c-13.653333 13.653333-13.653333 34.133333 0 47.786667 13.653333 13.653333 34.133333 13.653333 47.786666 0 13.653333-13.653333 13.653333-34.133333 0-47.786667-13.653333-13.653333-34.133333-13.653333-47.786666 0z m-64.853334 71.68c-13.653333 13.653333-13.653333 34.133333 0 47.786667 13.653333 13.653333 34.133333 13.653333 47.786667 0 13.653333-13.653333 13.653333-34.133333 0-47.786667-13.653333-13.653333-34.133333-13.653333-47.786667 0z',
  store: 'M20 4H4v2h16V4zm1 10v-2l-1-5H4l-1 5v2h1v6h10v-6h4v6h2v-6h1zm-9 4H6v-4h6v4z',
  history:
    'M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z',
  settings:
    'M19.14 12.94c.04-.31.06-.63.06-.94 0-.31-.02-.63-.06-.94l2.03-1.58c.18-.14.23-.41.12-.61l-1.92-3.32c-.12-.22-.37-.29-.59-.22l-2.39.96c-.5-.38-1.03-.7-1.62-.94l-.36-2.54c-.04-.24-.24-.41-.48-.41h-3.84c-.24 0-.43.17-.47.41l-.36 2.54c-.59.24-1.13.57-1.62.94l-2.39-.96c-.22-.08-.47 0-.59.22L2.74 8.87c-.12.21-.08.47.12.61l2.03 1.58c-.04.31-.06.63-.06.94s.02.63.06.94l-2.03 1.58c-.18.14-.23.41-.12.61l1.92 3.32c.12.22.37.29.59.22l2.39-.96c.5.38 1.03.7 1.62.94l.36 2.54c.05.24.24.41.48.41h3.84c.24 0 .44-.17.47-.41l.36-2.54c.59-.24 1.13-.56 1.62-.94l2.39.96c.22.08.47 0 .59-.22l1.92-3.32c.12-.22.07-.47-.12-.61l-2.01-1.58zM12 15.6c-1.98 0-3.6-1.62-3.6-3.6s1.62-3.6 3.6-3.6 3.6 1.62 3.6 3.6-1.62 3.6-3.6 3.6z'
}

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
  <div class="nav-wrapper">
    <nav class="nav nav-top">
      <router-link
        to="/"
        class="brand"
      >
        学豆
      </router-link>
      <div class="links links-desktop">
        <router-link
          v-for="item in navItems"
          :key="item.path"
          :to="item.path"
          active-class="active"
          class="link"
        >
          {{ item.label }}
        </router-link>
        <button
          type="button"
          class="btn-logout"
          @click="handleSignOut"
        >
          退出
        </button>
      </div>
      <div class="links-mobile">
        <button
          type="button"
          class="btn-logout"
          @click="handleSignOut"
        >
          退出
        </button>
      </div>
    </nav>
    <!-- 移动端底部导航（仅图标，文案由 aria-label 提供） -->
    <nav
      class="nav nav-bottom"
      aria-label="主导航"
    >
      <router-link
        v-for="item in navItems"
        :key="'bottom-' + item.path"
        :to="item.path"
        active-class="active"
        class="nav-bottom-link"
        :aria-label="item.label"
      >
        <svg
          class="nav-bottom-icon"
          :viewBox="item.icon === 'entertainment' ? '0 0 1024 1024' : '0 0 24 24'"
          fill="currentColor"
          aria-hidden="true"
        >
          <path
            v-if="navIcons[item.icon]"
            :d="navIcons[item.icon]"
            :stroke="item.icon === 'entertainment' ? 'currentColor' : undefined"
            :stroke-width="item.icon === 'entertainment' ? 36 : undefined"
            :stroke-linejoin="item.icon === 'entertainment' ? 'round' : undefined"
          />
        </svg>
      </router-link>
    </nav>
  </div>
</template>

<style scoped>
.nav-wrapper {
  position: relative;
}
.nav {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--space-md) var(--space-lg);
  background: var(--surface);
  border-bottom: 1px solid var(--border);
}
.nav-top {
  padding-left: max(var(--space-lg), env(safe-area-inset-left));
  padding-right: max(var(--space-lg), env(safe-area-inset-right));
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
  padding: var(--btn-padding-y, 0.65em) var(--space-sm);
  color: var(--text-muted);
  text-decoration: none;
  border-radius: var(--radius);
  min-height: var(--btn-min-height, 48px);
  align-items: center;
  display: inline-flex;
}
.link:hover,
.link.active {
  color: var(--primary);
  background: var(--primary-subtle);
}
.btn-logout {
  margin-left: var(--space-sm);
  padding: var(--btn-padding-y, 0.65em) var(--space-md);
  font-size: 0.95rem;
  color: var(--text-muted);
  background: transparent;
  border: 1px solid var(--border);
  border-radius: var(--radius);
  cursor: pointer;
  min-height: var(--btn-min-height, 48px);
  display: inline-flex;
  align-items: center;
  justify-content: center;
}
.btn-logout:hover {
  color: var(--danger);
  border-color: var(--danger);
}

/* 移动端：顶部只显示品牌 + 退出，底部固定导航 */
.links-mobile {
  display: none;
}
.nav-bottom {
  display: none;
}

@media (max-width: 768px) {
  .links-desktop {
    display: none;
  }
  .links-mobile {
    display: flex;
    align-items: center;
  }
  .nav-bottom {
    display: flex;
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    z-index: 100;
    background: var(--surface);
    border-top: 1px solid var(--border);
    padding: var(--space-xs);
    padding-left: max(var(--space-xs), env(safe-area-inset-left));
    padding-right: max(var(--space-xs), env(safe-area-inset-right));
    padding-bottom: max(var(--space-xs), env(safe-area-inset-bottom));
    justify-content: space-around;
    align-items: stretch;
  }
  .nav-bottom-link {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: var(--space-md);
    color: var(--text-muted);
    text-decoration: none;
    border-radius: var(--radius);
    min-height: var(--btn-min-height, 48px);
    touch-action: manipulation;
  }
  .nav-bottom-icon {
    width: 26px;
    height: 26px;
    display: block;
  }
  .nav-bottom-link:hover,
  .nav-bottom-link.active {
    color: var(--primary);
    background: var(--primary-subtle);
  }
}
</style>
