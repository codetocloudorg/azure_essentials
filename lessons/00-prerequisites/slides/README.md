# Azure Essentials Slides

Marp-based presentation slides for the Azure Essentials 2-day training course.

## Files

| File                       | Content                          |
| -------------------------- | -------------------------------- |
| `azure-essentials-day1.md` | Modules 1-7 (Foundations)        |
| `azure-essentials-day2.md` | Modules 8-12 (Advanced Services) |

## Viewing Slides

### VS Code (Recommended)

1. Install the **Marp for VS Code** extension
2. Open a slide file (`.md`)
3. Click the Marp icon in the top-right corner
4. Select **Open Preview to the Side**

### Browser

```bash
# Install Marp CLI
npm install -g @marp-team/marp-cli

# Serve with live reload
marp --server slides/
```

## Exporting to PowerPoint

```bash
# Export Day 1 to PPTX
marp azure-essentials-day1.md --pptx -o azure-essentials-day1.pptx

# Export Day 2 to PPTX
marp azure-essentials-day2.md --pptx -o azure-essentials-day2.pptx

# Export both
marp azure-essentials-day1.md --pptx && marp azure-essentials-day2.md --pptx
```

## Other Export Options

```bash
# Export to PDF
marp azure-essentials-day1.md --pdf -o azure-essentials-day1.pdf

# Export to HTML (self-contained)
marp azure-essentials-day1.md --html -o azure-essentials-day1.html
```

## Customization

### Themes

Change the theme in the frontmatter:

```yaml
---
marp: true
theme: default # Options: default, gaia, uncover
---
```

### Custom Styling

Modify the `style` block in the frontmatter to adjust fonts, colors, etc.

### Adding Images

```markdown
# Slide with Image

![width:600px](path/to/image.png)

# Background Image

![bg right:40%](path/to/image.png)
```

## Resources

- [Marp Documentation](https://marp.app/)
- [Marp VS Code Extension](https://marketplace.visualstudio.com/items?itemName=marp-team.marp-vscode)
- [Marp CLI](https://github.com/marp-team/marp-cli)
