import pluginVue from 'eslint-plugin-vue'

// 需要 Node 18+ 运行 npm run lint（ESLint 10 使用 structuredClone）
export default [
  ...pluginVue.configs['flat/recommended'],
  {
    files: ['**/*.vue', '**/*.js'],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      globals: {
        import: 'readonly',
        meta: 'readonly'
      }
    },
    rules: {
      'vue/multi-word-component-names': 'off'
    }
  }
]
