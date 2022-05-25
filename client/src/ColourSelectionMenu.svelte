<script lang="ts">
  import characters from "../data/characters.json";
  import colours from "../data/colours.json";
  import { get_next_menu_scene_id, get_previous_menu_scene_id } from "./utils";

  export let scene_id: string;
  export let character_id: string;
  export let colour_id: string;
  export let ws: WebSocket;

  const set_colour_id = (_colour_id: string) => {
    colour_id = _colour_id;
    const data = { action: "set_colour_id", colour_id: colour_id };
    console.log(data);
    ws.send(JSON.stringify(data));
  };
</script>

<div class="header split">
  <button
    on:click={() => (scene_id = get_previous_menu_scene_id(scene_id))}
    class="back-button"
  >
    <img src="/images/back-button.png" alt="Back" />
  </button>

  <h1>Pick a colour</h1>
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
  Yeah, this colour!
</button>

<div class="selection-grid">
  {#each colours as colour}
    <button
      on:click={() => set_colour_id(colour.id)}
      class="colour"
      style="background-color: #{colour.hex}"
    />
  {/each}
</div>
