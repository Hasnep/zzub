<script lang="ts">
  import { get_colour_hex_by_id } from "./utils";
  import menu_scene_ids from "../data/menu_scene_ids.json";
  import CharacterSelectionMenu from "./CharacterSelectionMenu.svelte";
  import Game from "./Game.svelte";
  import ColourSelectionMenu from "./ColourSelectionMenu.svelte";
  import PlayerNameSelectionMenu from "./PlayerNameSelectionMenu.svelte";
  import ReadyMenu from "./ReadyMenu.svelte";

  let scene_id = menu_scene_ids[0];
  let question: string = null;
  let answers: string[] = null;
  let player_id = Math.random().toString(36).substring(2, 6);
  let player_name: string = null;
  let selected_answer_index: number = null;
  let character_id: string;
  let colour_id: string;
  let is_ready: boolean = false;

  const ws_host = process.env.SERVER_HOST;
  const ws_port = process.env.SERVER_PORT;
  const server_path = "player";
  const websocket_url = `ws://${ws_host}:${ws_port}/${server_path}/${player_id}`;
  console.log(`Connecting to websocket "${websocket_url}".`);
  let ws = new WebSocket(websocket_url);
  ws.onopen = (e: Event) => {
    console.log("Websocket is open!");
    scene_id = "character_selection_menu";
  };
  ws.onmessage = (e: MessageEvent) => {
    const message = JSON.parse(e.data);
    console.log(message);
    const action = message["action"];
    if (action == "set_scene_id") {
      scene_id = message["scene_id"];
    } else if (action == "set_question") {
      selected_answer_index = null;
      question = message["question"];
      answers = message["answers"];
    } else if (action == "reveal_answer") {
    } else {
      console.log("vvv Unknown action:");
      console.log(message);
      console.log("^^^ That was the unknown action.");
    }
  };

  // const get_connection_text = (state_code): string => {
  //   const strings = ["Connecting...", "AAA", "BBB", "CCC"];
  //   return strings[state_code];
  // };
  // const connection_text: string;
  // $: connection_text = get_connection_text(ws.readyState);
</script>

<svelte:head>
  <title>Zzub</title>
  <meta name="robots" content="noindex nofollow" />
  <html lang="en" />
</svelte:head>

<div
  id="main-bg"
  style="background-color: #{get_colour_hex_by_id(colour_id)}"
/>
<main>
  {#if scene_id == "loading"}
    <h1>Loading</h1>
  {:else if scene_id == "character_selection_menu"}
    <CharacterSelectionMenu
      bind:scene_id
      bind:character_id
      bind:colour_id
      bind:ws
    />
  {:else if scene_id == "colour_selection_menu"}
    <ColourSelectionMenu
      bind:scene_id
      bind:character_id
      bind:colour_id
      bind:ws
    />
  {:else if scene_id == "player_name_selection_menu"}
    <PlayerNameSelectionMenu
      bind:scene_id
      bind:character_id
      bind:player_name
      bind:ws
    />
  {:else if scene_id == "ready_menu"}
    <ReadyMenu
      bind:scene_id
      bind:character_id
      bind:player_name
      bind:is_ready
      bind:ws
    />
  {:else if scene_id == "game"}
    <Game
      bind:player_id
      bind:question
      bind:answers
      bind:selected_answer_index
      bind:ws
    />
  {:else}
    <p>Well something's gone wrong here...</p>
  {/if}
</main>
