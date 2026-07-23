# The Git & GitHub Pipeline

> Afternoon track of the **Sandboxes & GitHub Masterclass** — a hands-on, full-day intensive on modern Salesforce DevOps and environment strategy.

This repository is the workspace for the afternoon labs. The goal is to make **source control the single source of truth** and ship changes with confidence: stand up the workspace, bring your work into Git, manage releases, and resolve the clashes that come with working as a team.

> ### The golden rule of DevOps
> **"If it isn't in Git, it doesn't exist."**
>
> The source of truth shifts from clicks in a sandbox to versioned source control. If a change only lives in an org, it isn't real — it can't be reviewed, released, or recovered.

---

## What you'll practice

| # | Exercise | Type | You'll be able to… |
|---|----------|------|--------------------|
| 0 | [Set up the workspace](#exercise-0--set-up-the-workspace) | Setup | Connect VS Code, the `sf` CLI, and your sandbox |
| 1 | [Your first deployment pipeline](#exercise-1--your-first-deployment-pipeline) | Hands-on | Take a change from org → branch → PR → deploy |
| 2 | [Cross-environment dependencies](#exercise-2--cross-environment-dependencies) | Your turn | Reproduce a failed deploy and sequence the release |
| 3 | [Merge conflicts](#exercise-3--merge-conflicts) | Your turn | Trigger a conflict and resolve it locally |
| 4 | [Destructive changes & cleanup](#exercise-4--destructive-changes--cleanup) | Your turn | Delete metadata from an org, the right way |

---

## Prerequisites

- **Your own sandbox.** A dedicated sandbox has been provisioned for you — nothing you do will touch anyone else's environment. Login credentials were sent to your inbox; grab them before you start.
- **Git** installed and configured (`git config --global user.name` / `user.email`).
- **A GitHub account** with access to this repository.
- **VS Code** with the **Salesforce Extension Pack**.
- **The Salesforce CLI** (`sf`). Verify with `sf --version`.

---

## Exercise 0 · Set up the workspace

**Objective:** get a local workspace where every click in the org maps to a versioned file.

### VS Code & the CLI

1. Install the **Salesforce Extension Pack** and the **`sf` CLI**.
2. Authorize your org:
   ```bash
   sf org login web --alias my-sandbox
   ```
3. Set a default org so deploys & retrieves know their target:
   ```bash
   sf config set target-org my-sandbox
   ```

### The `force-app` structure

Every click in the org maps to a versioned local file:

```
force-app/main/default/
├─ classes/          → .cls + -meta.xml
├─ objects/          → fields, record types
├─ layouts/          → .layout-meta.xml
├─ flows/            → .flow-meta.xml
└─ permissionsets/   → .xml
```

---

## Exercise 1 · Your first deployment pipeline

> 🛠️ **Hands-on:** Copy the Git pipeline, and bring all changes from the previous exercises into Git.

**Objective:** run one change through the full branch-to-release loop.

| Step | Action | Command / where |
|------|--------|-----------------|
| 1 | **Create branch** — `feature/*` off `main` or `integration` | `git switch -c feature/my-change` |
| 2 | **Develop** in your sandbox or scratch org | Salesforce Setup |
| 3 | **Retrieve changes** — track & pull from the source org | `sf project retrieve start` |
| 4 | **Commit & push** — bundle changed files → push to Git | `git add` → `git commit` → `git push` |
| 5 | **Pull request** — review & merge to the next branch | GitHub |
| 6 | **Deploy** — manually or auto via YAML / CI | `sf project deploy start` / pipeline |

**Done when:** your sandbox change exists as committed files on a branch, in an open (or merged) pull request.

---

## Exercise 2 · Cross-environment dependencies

> 👉 **Your turn:** Reference a field from an unmerged branch in a Flow, deploy it, and reproduce the failed deployment.

**The problem:** a Flow references `Contact.Region__c`, but that field only exists in another feature branch that hasn't merged into the target environment yet. Every component carries a chain of dependencies — fields, record types, classes. When one half of that chain ships ahead of the other, the deploy fails on the missing reference.

- **Symptom:** deployment failed — missing dependency.

### Resolve it — land dependencies in order

1. **Map the chain.** List what each component depends on before you deploy — fields, record types, classes.
2. **Merge upstream first.** Land the dependency's branch into the target *before* the feature that needs it.
3. **Deploy together.** Or bundle both into one release so the field and the Flow arrive in the same job.

**Why?** A deployment fails the moment it references a component that doesn't exist in the target yet — and the error won't always tell you why. Mapping and sequencing dependencies turns a failed job into a predictable, repeatable release.

---

## Exercise 3 · Merge conflicts

> 👉 **Your turn:** Have two branches edit the same Apex method, push both, and trigger the conflict locally.

**The collision:** two devs both change `getRelatedCount()` on the same lines and push. Git can't decide which wins, so it marks the clash: `HEAD` is yours, `main` is incoming.

### Resolve, then commit

1. **Read both sides.** Understand what each branch was trying to do.
2. **Keep the right logic.** Edit to the intended result — sometimes a blend of both.
3. **Delete markers & commit.** Remove `<<<<<<<`, `=======`, `>>>>>>>`, then commit the merge.

**Why?** Leaving conflict markers in the file and committing anyway causes a deployment failure — or worse, broken logic that compiles but behaves incorrectly. Resolving locally means every merged change is intentional, not accidental.

---

## Exercise 4 · Destructive changes & cleanup

> 👉 **Your turn:** Delete a component in VS Code, deploy, and confirm it's still alive in the org afterwards.

**The problem:** removing a file locally and deploying leaves the component **alive** in the org. A standard deploy only *adds* and *updates* metadata — it never deletes.

### Tell the org what to remove — `destructiveChanges.xml`

```xml
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
  <types>
    <members>Region__c</members>
    <name>CustomField</name>
  </types>
</Package>
```

- Lists exactly which components to delete from the target.
- **Run it as a release:** pair it with a `package.xml` in one deployment. Deploy → the listed components are removed downstream.
- Version-controlled, repeatable cleanup — no manual clicking.

**Why?** Deleting a component locally and deploying leaves the old metadata alive in every target org forever. Orphaned fields, flows and classes accumulate silently — causing confusion, unexpected behavior, and security risks from permissions that no longer make sense.

---

## Branching model

```
feature/*  ──►  integration  ──►  (QA / UAT)  ──►  main / production
```

- One **feature per branch**, small reviewable commits.
- Merge upstream dependencies **before** the features that need them.
- Every change reaches production through a **pull request** — never develop directly in prod.

---

## AI-assisted deployment with Claude

Claude Code can run the whole flow — branch, commit, push and open the PR — write commit messages, resolve simple conflicts, trigger the pipeline, and report back on the deploy.

But **still know the fundamentals**: you need to read a diff to know if it's safe to merge, and when the pipeline fails, *you* diagnose it. Everything in these labs still applies underneath.

> Reference — commit & PR skills used by Claude Code:
> <https://github.com/anthropics/claude-code/tree/main/plugins/commit-commands>

---

## Take-home checklist — Git best practices

- [ ] If it isn't in Git, it doesn't exist
- [ ] One feature per branch, small reviewable commits
- [ ] Map dependencies before you deploy
- [ ] Resolve conflicts locally, then commit the merge
- [ ] Use `destructiveChanges.xml` for deletions
