# Untitled World

An open-world 2D MMORPG prototype built around player freedom, persistent world simulation, and emergent stories.

## Current prototype

- Choose a starting background: working family, merchant family, or noble family.
- Explore a small 2D wilderness with keyboard or mobile controls.
- Chop trees to gather logs, process logs into planks, and build a cabin.
- Save and continue locally in the same browser.

## Important limitations

This is an early single-player mechanics prototype. It does **not** yet provide online multiplayer, server-side character saves, a shared economy, or a persistent world. Browser-local saves are device/browser specific and can be lost.

## Run locally

Open index.html in a modern browser. No build step or dependencies are required.

## Project direction

The long-term design is a simulation-first world where players choose their own lives: work, craft, trade, build, own property, form families, participate in politics, and shape the world through their decisions. Quests and events may exist, but they should not dictate every player's path.

## Development principles

- Preserve meaningful player freedom.
- Make background and circumstances affect starting opportunities without predetermining outcomes.
- Build small, testable systems before attempting large-scale multiplayer.
- Keep world state and economy server-authoritative when online persistence is introduced.
