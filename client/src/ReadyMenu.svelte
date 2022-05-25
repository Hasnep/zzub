<script lang="ts">
  import { get_previous_menu_scene_id } from "./utils";
  export let scene_id: string;
  export let character_id: string;
  export let player_name: string;
  export let is_ready: boolean;
  export let ws: WebSocket;

  $: ready_menu_title = is_ready
    ? "You're done, now go annoy whoever's still picking their character..."
    : "Are you ready?";

  const set_is_ready = (_is_ready: boolean) => {
    is_ready = _is_ready;
    const data = { action: "set_is_ready", is_ready: is_ready };
    console.log(data);
    ws.send(JSON.stringify(data));
  };
</script>

<div class="header split">
  <button
    on:click={() => {
      set_is_ready(false);
      scene_id = get_previous_menu_scene_id(scene_id);
    }}
    class="back-button"
  >
    <img src="/images/back-button.png" alt="Back" />
  </button>

  <h1>
    {ready_menu_title}
  </h1>
</div>

<img
  src="/images/{character_id}-neutral.png"
  alt={character_id}
  class="character-picture"
/>

<div class="player-name">{player_name}</div>

<button
  on:click={() => {
    set_is_ready(true);
  }}
  class="centre"
>
  Ready
</button>
