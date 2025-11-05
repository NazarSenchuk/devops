module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',     // New feature
        'fix',      // Bug fix
        'docs',     // Documentation
        'style',    // Code style changes (formatting, etc)
        'refactor', // Code refactoring
        'test',     // Adding tests
        'chore',    // Maintenance tasks
        'revert',   // Revert changes
        'ci',       // CI/CD changes
        'build',     // Build system changes
        'perf'      // Performance improvements
      ]
    ],
    'type-case': [2, 'always', 'lower-case'],
    'type-empty': [2, 'never'],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 100]
  }
};
