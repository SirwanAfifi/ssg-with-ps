## Static Site Generator using PowerShell/GitHub Pages/GitHub Actions

This is a simple static site generator that uses PowerShell to generate a static site from Markdown files. It is designed to be used with GitHub Pages and GitHub Actions to automatically generate a static site from Markdown files in a GitHub repository.

### Publish a new post

- Create a new Markdown file in the `posts` folder
- Add the following YAML front matter to the top of the file:

```
---
title: اولین پست من
slug: hello
date: 2023-04-26
author: سیروان عفیفی
tags: [tag1, tag2, tag3]
excerpt: این یک پست تستی است در مورد اینکه چطور میتوانیم از این قالب استفاده کنیم
---
```

- Add the content of your post below the YAML front matter
- Commit and push your changes to GitHub
- GitHub Actions will automatically generate the static site and publish it to GitHub Pages
