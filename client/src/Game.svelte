<script lang="ts">
  export let question: string;
  export let answers: string[];
  export let player_id: string;
  export let ws: WebSocket;

  export const answer_question = (i: number) => {
    const data = {
      action: "answer_question",
      player_id: player_id,
      answer_index: i,
    };
    console.log(data);
    ws.send(JSON.stringify(data));
  };
</script>

<h1>{question}</h1>

<ul class="answers">
  {#each answers as answer, i}
    <li>
      <button on:click={() => answer_question(i)} class="answer">
        {answer}
      </button>
    </li>
  {/each}
</ul>
