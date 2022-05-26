<script lang="ts">
  import colours from "../data/colours.json";
  import characters from "../data/characters.json";
  import { sample, get_colour_hex_by_id } from "./utils";
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
  let character_id: string = null;
  let colour_id: string = sample(colours).id;
  let is_ready: boolean = false;

  const ws_host = process.env.SERVER_HOST;
  const ws_port = process.env.SERVER_PORT;
  console.log(ws_host);
  console.log(ws_port);
  const is_production = process.env.IS_PRODUCTION;
  const server_path = "player";
  const websocket_url = `ws://${ws_host}:${ws_port}/${server_path}/${player_id}`;
  console.log(websocket_url);
  let ws = new WebSocket(websocket_url);
  ws.onopen = (e: Event) => {
    console.log("websocket is open!");
    scene_id = "character_selection_menu";
  };
  ws.onmessage = (e: MessageEvent) => {
    const message = JSON.parse(e.data);
    console.log(message);
    const action = message["action"];
    if (action == "set_scene_id") {
      scene_id = message["scene_id"];
    } else if (action == "set_question") {
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
  <title>Jackbox test</title>
  <meta name="robots" content="noindex nofollow" />
  <html lang="en" />
</svelte:head>

<main style="background-color: #{get_colour_hex_by_id(colour_id)}">
  {#if scene_id == "loading"}
    <h1>Loading</h1>
  {:else if scene_id == "character_selection_menu"}
    <CharacterSelectionMenu bind:scene_id bind:character_id bind:ws />
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
    <Game bind:player_id bind:question bind:answers bind:ws />
  {:else}
    <p>Well something's gone wrong here...</p>
  {/if}
</main>
