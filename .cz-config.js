module.exports = {
  types: [
    {
      value: "improve",
      name: "improve: Some updates to existing functionality etc",
      title: "Improvements",
    },
    {
      value: "chore",
      name: "chore: Other changes",
      title: "Chores",
    },
    {
      value: "feat",
      name: "feat: New feature",
      title: "Features",
    },
    {
      value: "fix",
      name: "fix: Bug fix",
      title: "Bug Fixes",
    },
    {
      value: "docs",
      name: "docs: Changes to documentation only",
      title: "Documentation",
    },
    {
      value: "style",
      name: "style: Changes to appearance that do not affect functionality",
      title: "Styles",
    },
    {
      value: "revert",
      name: "revert: (Release Notes)Reverting changes or removing existing features",
      title: "Reverts",
    },
    {
      value: "refactor",
      name: "refactor: (Release Notes)Code changes that are not bug fixes or feature additions",
      title: "Code Refactoring",
    },
    {
      value: "perf",
      name: "perf: (Release Notes)Changes to improve performance",
      title: "Performance",
    },
    {
      value: "test",
      name: "test: Adding missing tests or modifying existing tests",
      title: "Tests",
    },
    {
      value: "build",
      name: "build: Changes to build process or dependencies",
      title: "Build",
    },
    {
      value: "ci",
      name: "ci: Changes to CI configuration or scripts",
      title: "CI",
    },
  ],
  messages: {
    type: "Select type:\n",
    scope: "Select scope (press Enter to skip):\n",
    subject: "Enter subject:\n",
    confirmCommit: "Proceed with the commit:\n",
    // ticketNumber: "Enter ticket number (press Enter to skip):\n",
  },
  skipQuestions: ["body", "breaking", "footer"],
  scopes: [
    "",
    // Core modules
    "marks",
    "features",
    "shared",
    "config",
    "api",
    "keymap",
    "util",
    // Specific marks modules
    "quote",
    "heading",
    "list",
    "olist",
    "checkbox",
    "codeblock",
    // Specific features modules
    "toggle",
    "convert",
    "autolist",
    "olist-recalc",
    // Testing
    "test",
    // Documentation & metadata
    "readme",
    "changelog",
    "claude",
    "docs",
    // Development & CI/CD
    "git",
    "workflow",
    "release",
    "setup",
    // Other
    "other",
  ],
  // for Ticket Number
  /* 
  allowBreakingChanges: ["feat", "fix"],
  allowTicketNumber: true,
  isTicketNumberRequired: false,
  ticketNumberPrefix: "#",
  ticketNumberRegExp: "",
  */
};
