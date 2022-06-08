<script lang="ts">
  import { onMount } from "svelte";
  import characters from "../data/characters.json";
  import colours from "../data/colours.json";
  import {
    get_next_menu_scene_id,
    sample,
    set_character_id,
    set_colour_id,
  } from "./utils";

  export let scene_id: string;
  export let character_id: string;
  export let colour_id: string;
  export let ws: WebSocket;

  onMount(() => {
    if (character_id === undefined || character_id === null) {
      character_id = sample(characters).id;
      set_character_id(ws, character_id);
    }

    if (colour_id === undefined || colour_id === null) {
      colour_id = sample(colours).id;
      set_colour_id(ws, colour_id);
    }
  });
</script>

<div class="header">
  <h1>Pick a character</h1>
</div>

<img
  src="/images/{character_id}-neutral.png"
  alt={character_id}
  class="character-picture"
/>

<button
  on:click={() => (scene_id = get_next_menu_scene_id(scene_id))}
  class="centre"
>
  Yeah, this guy!
</button>

<div class="selection-grid">
  {#each characters as character, i}
    <button
      on:click={() => {
        character_id = character.id;
        set_character_id(ws, character_id);
      }}
      class="character"
      style="background-color: #{colours[i].hex}"
    >
      <img src="/images/{character.id}-neutral.png" alt={character.name} />
    </button>
  {/each}
</div>
