<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Validation\Rule;

class MobileChatController extends Controller
{
    private const SYSTEM_PROMPT = <<<'PROMPT'
You are SafeSpace AI, a friendly and empathetic
emotional support assistant for young adults.

Your purpose is to provide a safe, respectful,
non-judgmental space for everyday emotional support.

Guidelines:
- Respond with empathy and kindness.
- Be conversational, supportive and concise.
- Listen to the user's feelings before giving advice.
- Ask helpful follow-up questions when appropriate.
- Suggest practical self-care and coping strategies.
- Respond in the user's language whenever possible.
- Never judge, insult or shame the user.
- Never claim to be a human or licensed therapist.
- Never provide medical diagnoses or treatment plans.
- Do not invent facts or claim certainty when unsure.
- Do not promise absolute privacy or confidentiality.
- If the user mentions immediate danger, suicide,
  or self-harm, respond compassionately, encourage
  urgent help from local emergency services and
  reaching a trusted person in the real world.
- Do not encourage harmful or dangerous behavior.

You are an AI assistant, not a replacement for
professional mental health support.
PROMPT;

    // ==========================================
    // POST /api/chat
    // ==========================================
    public function send(Request $request)
    {
        // Validate incoming chat request
        $validated = $request->validate([
            'message' => [
                'required',
                'string',
                'max:1000',
            ],

            'history' => [
                'sometimes',
                'array',
                'max:12',
            ],

            'history.*.role' => [
                'required',
                Rule::in(['user', 'assistant']),
            ],

            'history.*.content' => [
                'required',
                'string',
                'max:1200',
            ],
        ]);

        $message = trim($validated['message']);

        if ($message === '') {
            return response()->json([
                'success' => false,
                'message' => 'Message cannot be empty.',
            ], 422);
        }

        // Never accept client-provided system messages.
        $messages = [
            [
                'role' => 'system',
                'content' => self::SYSTEM_PROMPT,
            ],
        ];

        // Keep a short temporary conversation context
        $history = array_slice(
            $validated['history'] ?? [],
            -8
        );

        foreach ($history as $item) {
            $content = trim($item['content']);

            if ($content !== '') {
                $messages[] = [
                    'role' => $item['role'],
                    'content' => $content,
                ];
            }
        }

        // Add current user message
        $messages[] = [
            'role' => 'user',
            'content' => $message,
        ];

        $url = rtrim(
            config('safespace_ai.url'),
            '/'
        );

        $model = config(
            'safespace_ai.model',
            'llama3'
        );

        try {
            // Send request to local Ollama
            $response = Http::acceptJson()
                ->asJson()
                ->connectTimeout(5)
                ->timeout(180)
                ->post(
                    $url . '/api/chat',
                    [
                        'model' => $model,
                        'messages' => $messages,

                        // Return one complete JSON response
                        'stream' => false,

                        // Keep the model loaded briefly
                        'keep_alive' => '5m',

                        'options' => [
                            'temperature' => 0.6,
                            'num_ctx' => 2048,
                            'num_predict' => 220,
                        ],
                    ]
                );

            if ($response->failed()) {
                return response()->json([
                    'success' => false,
                    'message' =>
                        'Ollama could not process the request. Check that the llama3 model is available.',
                ], 503);
            }

            $reply = $response->json(
                'message.content'
            );

            if (
                !is_string($reply) ||
                trim($reply) === ''
            ) {
                return response()->json([
                    'success' => false,
                    'message' =>
                        'The AI returned an empty response.',
                ], 502);
            }

            return response()->json([
                'success' => true,
                'reply' => trim($reply),
                'model' => $model,
            ]);

        } catch (ConnectionException $exception) {
            // Avoid returning private conversation
            // or internal exception details.
            return response()->json([
                'success' => false,
                'message' =>
                    'AI service unavailable or timed out. Please try again.',
            ], 503);
        }
    }
}
