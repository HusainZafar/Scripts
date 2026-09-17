# Webpage Summarizer

A Tampermonkey userscript that summarizes the current webpage using Google's Gemini API. Press a keyboard shortcut, get a bullet-point summary in a floating box — no copy-pasting into a chat window.

## Features

- **Keyboard trigger** — `Option+S` on Mac / `Alt+S` on Windows/Linux (uses the physical key code so Mac's Option-key character remapping doesn't break it)
- **Floating summary box** — appears top-right, dismissible, scrolls if long
- **Smart content extraction** — prefers `<article>` or `<main>` over the whole page, so nav/ads/sidebars don't pollute the summary
- **Free tier friendly** — uses `gemini-3.6-flash` with thinking mode disabled, keeping requests fast and within Google AI Studio's free quota for casual use

## Setup

1. Install [Tampermonkey](https://www.tampermonkey.net/) for your browser.
2. Open the Tampermonkey dashboard → **Create a new script**.
3. Delete the default boilerplate and paste in the contents of `webpage-summarizer.user.js`.
4. Save (Cmd/Ctrl+S).
5. Get a free API key at [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey) (no credit card required).
6. Visit any page and press `Option+S` / `Alt+S` — you'll be prompted for the key once, then it's stored locally via Tampermonkey's storage.

## Notes & caveats

- **Free tier data use**: Google's free tier terms allow using your prompts and page content to improve their models. Fine for public articles; avoid using this on private or confidential pages while on the free tier.
- **Model names change**: Google periodically deprecates and renames Gemini models. If the script stops working with a model-not-found error, check [ai.google.dev](https://ai.google.dev/gemini-api/docs/models) for the current model list and update the `MODEL` constant near the top of the script.
- **API key storage**: the key lives in Tampermonkey's local script storage (`GM_setValue`), not in the script file itself — safe to share this script publicly without leaking your key.
- **Cost**: even outside the free tier, summarizing a single page costs a fraction of a cent. This is not a high-volume/production tool.

## License

MIT — do whatever you want with it.
