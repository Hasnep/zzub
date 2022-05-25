<script lang="ts">
  import { onMount } from "svelte";
  import characters from "../data/characters.json";
  import colours from "../data/colours.json";
  import { get_character_name, get_next_menu_scene_id, sample } from "./utils";

  export let scene_id: string;
  export let character_id: string;
  export let ws: WebSocket;

  onMount(() => {
    if (character_id === undefined || character_id === null) {
      set_character_id(sample(characters).id);
    }
  });

  const set_character_id = (_character_id: string) => {
    character_id = _character_id;
    const data = { action: "set_character_id", character_id: character_id };
    console.log(data);
    ws.send(JSON.stringify(data));
  };
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
      on:click={() => set_character_id(character.id)}
      class="character"
      style="background-color: #{colours[i].hex}"
    >
      <img src="/images/{character.id}-neutral.png" alt={character.name} />
    </button>
  {/each}
</div>
