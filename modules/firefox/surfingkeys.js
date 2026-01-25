// Catppuccin surfingkeys theme
// Based on https://github.com/rose-pine/surfingkeys/blob/ddd220741e53455befa54871155c2708086d541d/template.js

// Catppuccin Mocha
const catppuccin = {
	rosewater: "#f5e0dc",
	flamingo: "#f2cdcd",
	pink: "#f5c2e7",
	mauve: "#cba6f7",
	red: "#f38ba8",
	maroon: "#eba0ac",
	peach: "#fab387",
	yellow: "#f9e2af",
	green: "#a6e3a1",
	teal: "#94e2d5",
	sky: "#89dceb",
	sapphire: "#74c7ec",
	blue: "#89b4fa",
	lavender: "#89b4fa",
	text: "#cdd6f4",
	subtext1: "#bac2de",
	subtext0: "#a6adc8",
	overlay2: "#9399b2",
	overlay1: "#7f849c",
	overlay0: "#6c7086",
	surface2: "#585b70",
	surface1: "#45475a",
	surface0: "#313244",
	base: "#1e1e2e",
	mantle: "#181825",
	crust: "#11111b",
}

const hintsCss = `
	font-size: 13pt;
	font-family: "Fira Code";
	border: 0px;
	color: ${catppuccin.text} !important;
	background: ${catppuccin.base};
	background-color: ${catppuccin.base}
`

api.Hints.style(hintsCss)
api.Hints.style(hintsCss, "text")

settings.theme = `
	.sk_theme {
		background: ${catppuccin.base};
		color: ${catppuccin.text};
	}
	.sk_theme input {
		color: ${catppuccin.text};
	}
	.sk_theme .url {
		color: ${catppuccin.mauve};
	}
	.sk_theme .annotation {
		color: ${catppuccin.rosewater};
	}
	.sk_theme kbd {
		background: ${catppuccin.overlay0};
		color: ${catppuccin.text};
	}
	.sk_theme .frame {
		background: ${catppuccin.surface0};
	}
	.sk_theme .omnibar_highlight {
		color: ${catppuccin.overlay2};
	}
	.sk_theme .omnibar_folder {
		color: ${catppuccin.text};
	}
	.sk_theme .omnibar_timestamp {
		color: ${catppuccin.sapphire};
	}
	.sk_theme .omnibar_visitcount {
		color: ${catppuccin.sapphire};
	}
	.sk_theme .prompt, .sk_theme .resultPage {
		color: ${catppuccin.text};
	}
	.sk_theme .feature_name {
		color: ${catppuccin.text};
	}
	.sk_theme .separator {
		color: ${catppuccin.overlay2};
	}
	body {
		margin: 0;

		font-family: "Fira Code" !important;
		font-size: 12px;
	}
	#sk_omnibar {
		overflow: hidden;
		position: fixed;
		width: 80%;
		max-height: 80%;
		left: 10%;
		text-align: left;
		box-shadow: 0px 2px 10px ${catppuccin.overlay0};
		z-index: 2147483000;
	}
	.sk_omnibar_middle {
		top: 10%;
		border-radius: 4px;
	}
	.sk_omnibar_bottom {
		bottom: 0;
		border-radius: 4px 4px 0px 0px;
	}
	#sk_omnibar span.omnibar_highlight {
		text-shadow: 0 0 0.01em;
	}
	#sk_omnibarSearchArea .prompt, #sk_omnibarSearchArea .resultPage {
		display: inline-block;
		font-size: 20px;
		width: auto;
	}
	#sk_omnibarSearchArea>input {
		display: inline-block;
		width: 100%;
		flex: 1;
		font-size: 20px;
		margin-bottom: 0;
		padding: 0px 0px 0px 0.5rem;
		background: transparent;
		border-style: none;
		outline: none;
	}
	#sk_omnibarSearchArea {
		display: flex;
		align-items: center;
		border-bottom: 1px solid ${catppuccin.overlay2};
	}
	.sk_omnibar_middle #sk_omnibarSearchArea {
		margin: 0.5rem 1rem;
	}
	.sk_omnibar_bottom #sk_omnibarSearchArea {
		margin: 0.2rem 1rem;
	}
	.sk_omnibar_middle #sk_omnibarSearchResult>ul {
		margin-top: 0;
	}
	.sk_omnibar_bottom #sk_omnibarSearchResult>ul {
		margin-bottom: 0;
	}
	#sk_omnibarSearchResult {
		max-height: 60vh;
		overflow: hidden;
		margin: 0rem 0.6rem;
	}
	#sk_omnibarSearchResult:empty {
		display: none;
	}
	#sk_omnibarSearchResult>ul {
		padding: 0;
	}
	#sk_omnibarSearchResult>ul>li {
		padding: 0.2rem 0rem;
		display: block;
		max-height: 600px;
		overflow-x: hidden;
		overflow-y: auto;
	}
	.sk_theme #sk_omnibarSearchResult>ul>li:nth-child(odd) {
		background: ${catppuccin.surface0};
	}
	.sk_theme #sk_omnibarSearchResult>ul>li.focused {
		background: ${catppuccin.overlay0};
	}
	.sk_theme #sk_omnibarSearchResult>ul>li.window {
		border: 2px solid ${catppuccin.overlay2};
		border-radius: 8px;
		margin: 4px 0px;
	}
	.sk_theme #sk_omnibarSearchResult>ul>li.window.focused {
		border: 2px solid ${catppuccin.mauve};
	}
	.sk_theme div.table {
		display: table;
	}
	.sk_theme div.table>* {
		vertical-align: middle;
		display: table-cell;
	}
	#sk_omnibarSearchResult li div.title {
		text-align: left;
	}
	#sk_omnibarSearchResult li div.url {
		font-weight: bold;
		white-space: nowrap;
	}
	#sk_omnibarSearchResult li.focused div.url {
		white-space: normal;
	}
	#sk_omnibarSearchResult li span.annotation {
		float: right;
	}
	#sk_omnibarSearchResult .tab_in_window {
		display: inline-block;
		padding: 5px;
		margin: 5px;
		box-shadow: 0px 2px 10px ${catppuccin.overlay0};
	}
	#sk_status {
		position: fixed;
		bottom: 0;
		right: 20%;
		z-index: 2147483000;
		padding: 4px 8px 0 8px;
		border-radius: 4px 4px 0px 0px;
		border: 1px solid ${catppuccin.overlay2};
		font-size: 12px;
	}
	#sk_status>span {
		line-height: 16px;
	}
	.expandRichHints span.annotation {
		padding-left: 4px;
		color: ${catppuccin.rosewater};
	}
	.expandRichHints .kbd-span {
		min-width: 30px;
		text-align: right;
		display: inline-block;
	}
	.expandRichHints kbd>.candidates {
		color: ${catppuccin.text};
		font-weight: bold;
	}
	.expandRichHints kbd {
		padding: 1px 2px;
	}
	#sk_find {
		border-style: none;
		outline: none;
	}
	#sk_keystroke {
		padding: 6px;
		position: fixed;
		float: right;
		bottom: 0px;
		z-index: 2147483000;
		right: 0px;
		background: ${catppuccin.base};
		color: ${catppuccin.text};
	}
	#sk_usage, #sk_popup, #sk_editor {
		overflow: auto;
		position: fixed;
		width: 80%;
		max-height: 80%;
		top: 10%;
		left: 10%;
		text-align: left;
		box-shadow: ${catppuccin.overlay0};
		z-index: 2147483298;
		padding: 1rem;
	}
	#sk_nvim {
		position: fixed;
		top: 10%;
		left: 10%;
		width: 80%;
		height: 30%;
	}
	#sk_popup img {
		width: 100%;
	}
	#sk_usage>div {
		display: inline-block;
		vertical-align: top;
	}
	#sk_usage .kbd-span {
		width: 80px;
		text-align: right;
		display: inline-block;
	}
	#sk_usage .feature_name {
		text-align: center;
		padding-bottom: 4px;
	}
	#sk_usage .feature_name>span {
		border-bottom: 2px solid ${catppuccin.overlay2};
	}
	#sk_usage span.annotation {
		padding-left: 32px;
		line-height: 22px;
	}
	#sk_usage * {
		font-size: 10pt;
	}
	kbd {
		white-space: nowrap;
		display: inline-block;
		padding: 3px 5px;
		font: 11px "Fira Code";
		line-height: 10px;
		vertical-align: middle;
		border: solid 1px ${catppuccin.overlay2};
		border-bottom-lolor: ${catppuccin.overlay2};
		border-radius: 3px;
		box-shadow: inset 0 -1px 0 ${catppuccin.overlay0};
	}
	#sk_banner {
		padding: 0.5rem;
		position: fixed;
		left: 10%;
		top: -3rem;
		z-index: 2147483000;
		width: 80%;
		border-radius: 8px 8px 8px 8px;
		border: 2px solid ${catppuccin.rosewater};
		color: ${catppuccin.yellow};
		text-align: center;
		background: ${catppuccin.base};
		white-space: nowrap;
		text-overflow: ellipsis;
		overflow: hidden;
	}
	#sk_tabs {
		position: fixed;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		background: transparent;
		overflow: auto;
		z-index: 2147483000;
	}
	div.sk_tab {
		display: inline-flex;
		height: 28px;
		width: 202px;
		justify-content: space-between;
		align-items: center;
		flex-direction: row-reverse;
		border-radius: 3px;
		padding: 10px 20px;
		margin: 5px;
		background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,${catppuccin.base}), color-stop(100%,${catppuccin.base}));
		box-shadow: 0px 3px 7px 0px ${catppuccin.overlay0};
	}
	div.sk_tab_wrap {
		display: inline-block;
		flex: 1;
	}
	div.sk_tab_icon {
		display: inline-block;
		vertical-align: middle;
	}
	div.sk_tab_icon>img {
		width: 18px;
	}
	div.sk_tab_title {
		width: 150px;
		display: inline-block;
		vertical-align: middle;
		font-size: 10pt;
		white-space: nowrap;
		text-overflow: ellipsis;
		overflow: hidden;
		padding-left: 5px;
		color: ${catppuccin.text};
	}
	div.sk_tab_url {
		font-size: 10pt;
		white-space: nowrap;
		text-overflow: ellipsis;
		overflow: hidden;
		color: ${catppuccin.mauve};
	}
	div.sk_tab_hint {
		display: inline-block;
		float:right;
		font-size: 10pt;
		font-weight: bold;
		padding: 0px 2px 0px 2px;
		background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,${catppuccin.base}), color-stop(100%,${catppuccin.base}));
		color: ${catppuccin.text};
		border: solid 1px ${catppuccin.overlay2};
		border-radius: 3px;
		box-shadow: ${catppuccin.overlay0};
	}
	#sk_tabs.vertical div.sk_tab_hint {
		position: initial;
		margin-inline: 0;
	}
	div.tab_rocket {
		display: none;
	}
	#sk_bubble {
		position: absolute;
		padding: 9px;
		border: 1px solid ${catppuccin.overlay2};
		border-radius: 4px;
		box-shadow: 0 0 20px ${catppuccin.overlay0};
		color: ${catppuccin.text};
		background-color: ${catppuccin.base};
		z-index: 2147483000;
		font-size: 14px;
	}
	#sk_bubble .sk_bubble_content {
		overflow-y: scroll;
		background-size: 3px 100%;
		background-position: 100%;
		background-repeat: no-repeat;
	}
	.sk_scroller_indicator_top {
		background-image: linear-gradient(${catppuccin.base}, transparent);
	}
	.sk_scroller_indicator_middle {
		background-image: linear-gradient(transparent, ${catppuccin.base}, transparent);
	}
	.sk_scroller_indicator_bottom {
		background-image: linear-gradient(transparent, ${catppuccin.base});
	}
	#sk_bubble * {
		color: ${catppuccin.text} !important;
	}
	div.sk_arrow>div:nth-of-type(1) {
		left: 0;
		position: absolute;
		width: 0;
		border-left: 12px solid transparent;
		border-right: 12px solid transparent;
		background: transparent;
	}
	div.sk_arrow[dir=down]>div:nth-of-type(1) {
		border-top: 12px solid ${catppuccin.overlay2};
	}
	div.sk_arrow[dir=up]>div:nth-of-type(1) {
		border-bottom: 12px solid ${catppuccin.overlay2};
	}
	div.sk_arrow>div:nth-of-type(2) {
		left: 2px;
		position: absolute;
		width: 0;
		border-left: 10px solid transparent;
		border-right: 10px solid transparent;
		background: transparent;
	}
	div.sk_arrow[dir=down]>div:nth-of-type(2) {
		border-top: 10px solid ${catppuccin.text};
	}
	div.sk_arrow[dir=up]>div:nth-of-type(2) {
		top: 2px;
		border-bottom: 10px solid ${catppuccin.text};
	}
	.ace_editor.ace_autocomplete {
		z-index: 2147483300 !important;
		width: 80% !important;
	}
	@media only screen and (max-width: 767px) {
		#sk_omnibar {
			width: 100%;
			left: 0;
		}
		#sk_omnibarSearchResult {
			max-height: 50vh;
			overflow: scroll;
		}
		.sk_omnibar_bottom #sk_omnibarSearchArea {
			margin: 0;
			padding: 0.2rem;
		}
	}
`

// Unmaps

api.unmap("s") // Search Selected With
api.unmap("Z") // Surfingkeys session management
api.unmap("A") // LLM Chat
api.unmap("o") // Omnibar
// Remap omnibar for vim-like marks
api.mapkey("om", "Omnibar for vim-like marks", () => {
	api.Front.openOmnibar({ type: "VIMarks" })
})
api.unmap("b") // Bookmarks omnibar
api.unmap("go") // Open a URL in current tab
api.unmap("t") // Open a URL
api.unmap("H") // Open opened URL in current tab
api.unmap("ab") // Bookmark current page to selected folder
api.unmap("Q") // Open omnibar for word translation
api.unmap("/") // Find in current page
