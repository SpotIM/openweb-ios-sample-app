# OpenWeb Showcase

A SwiftUI demo app showcasing the OpenWeb SDK's engagement solutions across multiple content verticals.

## Overview

The Showcase app demonstrates best practices for integrating OpenWeb's conversation and engagement features into different content types. Each vertical presents a unique integration pattern tailored to its content format.

## SDK Integration

Each vertical screen (`UI/<Vertical>Screen/`) demonstrates the two steps required to display an SDK component:

**Setting SDK parameters** (in ViewModels):
- `OpenWeb.manager.spotId` — Set the spot ID for the conversation
- `OpenWeb.manager.ui.customizations.customizedTheme.brandColor` — Configure brand color

**Integrating SDK views** (in Views):
- `OpenWebPreConversation(postId:article:)` — Embed a pre-conversation module
