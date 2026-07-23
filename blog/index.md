---
title: Blog
nav_order: 1
has_children: true
description: Technical deep dives, investigation notes, and lessons learned.
permalink: /blog/
---

## Latest articles

{% if site.posts.size > 0 %}
{% for post in site.posts %}
### [{{ post.title }}]({{ post.url | relative_url }})

{{ post.date | date: "%Y-%m-%d" }}{% if post.tags %} · {{ post.tags | join: ", " }}{% endif %}

{{ post.description | default: post.excerpt | strip_html | truncate: 240 }}
{% endfor %}
{% else %}
Long-form technical articles and investigation notes will appear here.
{% endif %}
