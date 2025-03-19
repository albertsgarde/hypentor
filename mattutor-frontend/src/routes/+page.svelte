<script lang="ts">
	import IconSend from '@lucide/svelte/icons/send-horizontal';
	import { OpenAI } from 'openai';

	interface Message {
		id: number;
		host: boolean;
		name: string;
		message: string;
		color: string;
	}

	let elemChat: HTMLElement;

	// Messages
	let messageFeed: Message[] = [];
	let currentMessage = '';

	let previousResponseId: string | null = null;

	// Use a throwaway api key that only has access to $0.1 each month. Should obviously be done in a better way in future.
	const client = new OpenAI({
		apiKey:
			'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',
		dangerouslyAllowBrowser: true
	});

	function scrollChatBottom(behavior?: 'auto' | 'instant' | 'smooth') {
		elemChat.scrollTo({ top: elemChat.scrollHeight, behavior });
	}

	async function getResponse(
		userMessage: string,
		previousResponseId: string | null
	): Promise<{ message: string; id: string }> {
		const response = await client.responses
			.create({
				model: 'gpt-4o-mini',
				input: [
					{
						role: 'developer',
						content:
							'You are a tutor helping a student with their homework. Do not provide direct answers, but help guide them to the solution. They will ask questions in Danish and you should answer exclusively in Danish. Please do not use LaTeX or similar notation since we have not yet implemented support for this.'
					},
					{
						role: 'user',
						content: userMessage
					}
				],
				previous_response_id: previousResponseId
			})
			.then((response) => {
				const responseId = response.id;
				const message = response.output_text;

				return { message, id: responseId };
			});
		return response;
	}

	function addMessage() {
		const userMessage = currentMessage;
		currentMessage = '';

		const newMessage = {
			id: messageFeed.length,
			host: true,
			name: 'User',
			message: userMessage,
			color: 'preset-tonal-primary'
		};
		// Update the message feed
		messageFeed = [...messageFeed, newMessage];

		// Smooth scroll to bottom
		// Timeout prevents race condition
		setTimeout(() => scrollChatBottom('smooth'), 0);

		getResponse(userMessage, previousResponseId).then(({ message, id }) => {
			previousResponseId = id;
			const newMessage = {
				id: messageFeed.length,
				host: false,
				name: 'Tutor',
				message: message,
				color: 'preset-tonal-secondary'
			};
			// Update the message feed
			messageFeed = [...messageFeed, newMessage];

			setTimeout(() => scrollChatBottom('smooth'), 0);
		});
	}

	function onPromptKeydown(event: KeyboardEvent) {
		if (['Enter'].includes(event.code)) {
			event.preventDefault();
			addMessage();
		}
	}
</script>

<section class="card bg-surface-100-900 rounded-container overflow-hidden">
	<div class="chat grid h-full w-full grid-cols-1 lg:grid-cols-[30%_1fr]">
		<!-- Chat -->
		<div class="grid-row-[1fr_auto] grid">
			<!-- Conversation -->
			<section bind:this={elemChat} class="max-h-[500px] space-y-4 overflow-y-auto p-4">
				{#each messageFeed as bubble}
					{#if bubble.host === true}
						<div class="grid grid-cols-[auto_1fr] gap-2">
							<div class="card preset-tonal space-y-2 rounded-tl-none p-4">
								<header class="flex items-center justify-between">
									<p class="font-bold">{bubble.name}</p>
								</header>
								<p>{bubble.message}</p>
							</div>
						</div>
					{:else}
						<div class="grid grid-cols-[1fr_auto] gap-2">
							<div class="card space-y-2 rounded-tr-none p-4 {bubble.color}">
								<header class="flex items-center justify-between">
									<p class="font-bold">{bubble.name}</p>
								</header>
								<p>{bubble.message}</p>
							</div>
						</div>
					{/if}
				{/each}
			</section>
			<!-- Prompt -->
			<section class="border-surface-200-800 border-t-[1px] p-4">
				<div class="input-group">
					<textarea
						value={currentMessage}
						oninput={(e) => (currentMessage = e.currentTarget.value)}
						class="border-0 bg-transparent ring-0"
						name="prompt"
						id="prompt"
						placeholder="Write a message..."
						rows="1"
						onkeydown={onPromptKeydown}
					></textarea>
					<button
						class="input-group-cell {currentMessage ? 'preset-filled-primary-500' : 'preset-tonal'}"
						onclick={addMessage}
					>
						<IconSend />
					</button>
				</div>
			</section>
		</div>
	</div>
</section>
