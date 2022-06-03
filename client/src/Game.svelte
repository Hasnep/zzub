<script lang="ts">
  export let question: string;
  export let answers: string[];
  export let player_id: string;
  export let ws: WebSocket;
  export let selected_answer_index: number = null;

  export const answer_question = (i: number) => {
    selected_answer_index = i;
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
  {#if answers !== null}
    {#each answers as answer, i}
      <li>
        {#if i == selected_answer_index}
          <button on:click={() => {}} class="answer selected">
            {answer}
          </button>
        {:else}
          <button on:click={() => answer_question(i)} class="answer">
            {answer}
          </button>
        {/if}
      </li>
    {/each}
  {/if}
</ul>
