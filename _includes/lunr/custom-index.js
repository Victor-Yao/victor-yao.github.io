{%- comment -%}
Register the Chinese tokenizer on the Lunr index builder.

Just the Docs includes this file inside its `for (var i in docs)` loop, but
`this.use()` has to run before any document is added. `this` inside that loop is
still the Lunr builder, so guarding on a flag applies the multi-language pipeline
during the first iteration and leaves every later iteration untouched.

Without this, Lunr treats a whole Chinese sentence as one token and no Chinese
query can ever match. lunr.zh.js is loaded from _includes/head_custom.html.
{%- endcomment -%}
if (!this._multiLanguageReady && typeof lunr.multiLanguage === 'function') {
  this.use(lunr.multiLanguage('en', 'zh'));
  this._multiLanguageReady = true;
}
