<script lang="ts">
  import {
    get_next_menu_scene_id,
    get_previous_menu_scene_id,
    get_character_name,
  } from "./utils";

  export let scene_id: string;
  export let character_id: string;
  export let player_name: string;
  export let ws: WebSocket;

  const set_player_name = (_player_name: string) => {
    player_name = _player_name;
    const data = { action: "set_player_name", player_name: player_name };
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

  <h1>Pick a name</h1>
</div>

<img
  src="/images/{character_id}-neutral.png"
  alt={character_id}
  class="character-picture"
/>

<button
  on:click={() => {
    if (player_name === null) {
      set_player_name(get_character_name(character_id));
    }
    scene_id = get_next_menu_scene_id(scene_id);
  }}
  class="centre"
>
  Let's get quizzical!
</button>

<input
  on:change={(e) => set_player_name(e.target.value)}
  placeholder={player_name}
  class="player-name-selection"
/>
