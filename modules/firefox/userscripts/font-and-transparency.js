// ==UserScript==
// @name font-and-transparency
// @description Change the font and make everything transparent!
// @match *://*/*
// @grant GM_addStyle
// @version 0.0.0
// @author bitbloxhub
// ==/UserScript==
// FIXME: New styles added with `insertRule` do not seem to trigger anything
// FIXME: Make it so transparency is layered and calculated

GM_addStyle(`
* {
	font-family: "Fira Code" !important;
}
:root {
	--yt-spec-base-background: rgb(from #1e1e2e r g b / 0.6) !important;
}
`)

const batchedStyleMods = []
const bodyComputedStyle = getComputedStyle(document.body)
const cachedBodyComputedStyle = {}

const modifySheet = (sheet) => {
	const process = (rule) => {
		const transparentifyColor = (color) => {
			if (color.startsWith("rgba")) {
				return `rgb(from ${color} r g b a / 0.6)`
			} else if (color.startsWith("rgb")) {
				return `rgb(from ${color} r g b / 0.6)`
			} else if (color.startsWith("hsla")) {
				return `hsl(from ${color} h s l a / 0.6)`
			} else if (color.startsWith("hsl")) {
				return `hsl(from ${color} h s l / 0.6)`
			} else if (color.startsWith("var")) {
				const var_name = color
					.substring(color.indexOf("--"), color.length)
					.split(",")[0]
					.replace(")", "")
				if (Object.hasOwn(cachedBodyComputedStyle, var_name)) {
					return transparentifyColor(
						cachedBodyComputedStyle[var_name],
					)
				} else {
					cachedBodyComputedStyle[var_name] =
						bodyComputedStyle.getPropertyValue(var_name)
					return transparentifyColor(
						cachedBodyComputedStyle[var_name],
					)
				}
			} else if (color.startsWith("light-dark")) {
				return transparentifyColor(
					color
						.substring(color.indexOf("(") + 1, color.length)
						.split(",")[1]
						.replace(")", ""),
				)
			} else if (color.startsWith("#")) {
				return `rgb(from ${color} r g b / 0.6)`
			} else {
				console.warn(`Unknown color: ${color}`)
			}
		}
		if (rule.cssRules) {
			Array.from(rule.cssRules).forEach(process)
		}
		if (rule.style && rule.style["background-color"]) {
			rule.style.setProperty(
				"background-color",
				transparentifyColor(rule.style["background-color"]),
				"important",
			)
			batchedStyleMods.push({
				selector: rule.selectorText,
				prop: "background-color",
				value: transparentifyColor(rule.style["background-color"]),
			})
		}
		if (rule.style && rule.style["background"]) {
			rule.style.setProperty(
				"background",
				transparentifyColor(rule.style["background"]),
				"important",
			)
			batchedStyleMods.push({
				selector: rule.selectorText,
				prop: "background",
				value: transparentifyColor(rule.style["background"]),
			})
		}
	}
	console.log(
		Array.from(sheet.cssRules).filter(
			(rule) => rule.selectorText == ".css-t7nozw",
		),
	)
	Array.from(sheet.cssRules).forEach(process)
}

Array.from(document.querySelectorAll("link[rel='stylesheet']")).forEach(
	(style) => {
		try {
			modifySheet(style.sheet)
		} catch (ex) {
			const newNode = style.cloneNode(true)
			newNode.setAttribute("crossorigin", "anonymous")
			newNode.onload = () => {
				style.remove()
				modifySheet(newNode.sheet)
			}
			style.parentElement.insertBefore(newNode, style)
		}
	},
)

Array.from(document.querySelectorAll("style")).forEach((style) => {
	console.log(style.sheet)
	try {
		modifySheet(style.sheet)
	} catch (ex) {
		const newNode = style.cloneNode(true)
		newNode.setAttribute("crossorigin", "anonymous")
		newNode.onload = () => {
			style.remove()
			modifySheet(newNode.sheet)
		}
		style.parentElement.insertBefore(newNode, style)
	}
})

new MutationObserver((mutationList, observer) => {
	const modifySheetWrapped = (sheet) => {
		try {
			modifySheet(sheet)
		} catch (ex) {
			const newNode = sheet.ownerNode.cloneNode(true)
			newNode.setAttribute("crossorigin", "anonymous")
			newNode.onload = () => {
				sheet.ownerNode.remove()
				modifySheet(newNode.sheet)
			}
			sheet.ownerNode.parentElement.insertBefore(newNode, sheet.ownerNode)
		}
	}
	mutationList
		.filter(
			(mutation) =>
				mutation.target.localName == "style" ||
				(mutation.target.localName == "link" &&
					mutation.target.rel == "stylesheet"),
		)
		.forEach((mutation) => {
			modifySheetWrapped(mutation.target.sheet)
		})

	mutationList.forEach((mutation) => {
		mutation.addedNodes.forEach((addedNode) => {
			if (
				addedNode.localName == "style" ||
				(addedNode.localName == "link" && addedNode.rel == "stylesheet")
			) {
				addedNode.onload = () => {
					modifySheetWrapped(addedNode.sheet)
				}
			}
		})
	})
	mutationList.forEach((mutation) => {
		if (mutation.type === "characterData") {
			console.log(mutation)
		}
	})
}).observe(document.documentElement, {
	attributes: true,
	childList: true,
	subtree: true,
})
