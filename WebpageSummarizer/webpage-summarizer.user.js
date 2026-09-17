// ==UserScript==
// @name         Gemini Page Summarizer
// @namespace    https://example.com/gemini-summarizer
// @version      1.0
// @description  Press Alt+S to summarize the current page with Gemini, shown in a floating box
// @match        *://*/*
// @grant        GM_xmlhttpRequest
// @grant        GM_setValue
// @grant        GM_getValue
// @connect      generativelanguage.googleapis.com
// ==/UserScript==

(function () {
  'use strict';

  const MODEL = 'gemini-3.6-flash'; // fast, free-tier-eligible modela
  const API_URL = `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`;
  const MAX_CHARS = 15000; // trims page text to keep requests fast/cheap

  function getApiKey() {
    let key = GM_getValue('gemini_api_key', '');
    if (!key) {
      key = prompt('Enter your Gemini API key (from aistudio.google.com/app/apikey):');
      if (key) GM_setValue('gemini_api_key', key.trim());
    }
    return key;
  }

  function extractPageText() {
    // Prefer <article> or <main> if present, else fall back to body text
    const container = document.querySelector('article') || document.querySelector('main') || document.body;
    let text = container.innerText || '';
    text = text.replace(/\s+\n/g, '\n').replace(/\n{3,}/g, '\n\n').trim();
    if (text.length > MAX_CHARS) text = text.slice(0, MAX_CHARS) + '\n\n[...truncated...]';
    return text;
  }

  function createBox() {
    let box = document.getElementById('claude-summary-box');
    if (box) return box;

    box = document.createElement('div');
    box.id = 'claude-summary-box';
    box.style.cssText = `
      position: fixed;
      top: 20px;
      right: 20px;
      width: 360px;
      max-height: 70vh;
      overflow-y: auto;
      background: #fff;
      color: #1a1a1a;
      border: 1px solid #ddd;
      border-radius: 10px;
      box-shadow: 0 8px 24px rgba(0,0,0,0.2);
      padding: 16px;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      font-size: 14px;
      line-height: 1.5;
      z-index: 2147483647;
    `;

    const closeBtn = document.createElement('button');
    closeBtn.textContent = '×';
    closeBtn.style.cssText = `
      position: absolute;
      top: 8px;
      right: 10px;
      border: none;
      background: none;
      font-size: 20px;
      cursor: pointer;
      color: #888;
    `;
    closeBtn.onclick = () => box.remove();
    box.appendChild(closeBtn);

    const content = document.createElement('div');
    content.id = 'claude-summary-content';
    content.style.marginTop = '8px';
    box.appendChild(content);

    document.body.appendChild(box);
    return box;
  }

  function setContent(html) {
    const box = createBox();
    document.getElementById('claude-summary-content').innerHTML = html;
  }

  function summarizePage() {
    const apiKey = getApiKey();
    if (!apiKey) return;

    setContent('<em>Summarizing…</em>');

    const pageText = extractPageText();
    const prompt = `Summarize the following webpage content in 4-6 short bullet points. Be concise and skip filler.\n\nTitle: ${document.title}\n\nContent:\n${pageText}`;

    GM_xmlhttpRequest({
      method: 'POST',
      url: `${API_URL}?key=${encodeURIComponent(apiKey)}`,
      headers: {
        'Content-Type': 'application/json',
      },
      data: JSON.stringify({
        contents: [{ role: 'user', parts: [{ text: prompt }] }],
        generationConfig: {
          maxOutputTokens: 800,
          thinkingConfig: { thinkingBudget: 0 },
        },
      }),
      onload: function (response) {
        try {
          const data = JSON.parse(response.responseText);
          if (data.error) {
            setContent(`<strong>Error:</strong> ${data.error.message || 'Unknown error'}`);
            return;
          }
          const text = (data.candidates?.[0]?.content?.parts || []).map((p) => p.text || '').join('\n');
          const html = text
            .split('\n')
            .filter((line) => line.trim())
            .map((line) => `<div style="margin-bottom:6px;">${line.replace(/^[-*]\s*/, '• ')}</div>`)
            .join('');
          setContent(html || '<em>No summary returned.</em>');
        } catch (e) {
          setContent('<strong>Error parsing response.</strong>');
        }
      },
      onerror: function () {
        setContent('<strong>Request failed.</strong> Check your API key and network.');
      },
    });
  }

  document.addEventListener('keydown', function (e) {
    // Alt/Option+S — use e.code (physical key) since Option on Mac
    // changes e.key to a special character (e.g. "ß") instead of "s"
    if (e.altKey && e.code === 'KeyS') {
      e.preventDefault();
      summarizePage();
    }
  });
})();
