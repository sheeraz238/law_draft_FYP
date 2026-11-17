const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers':
        'authorization, x-client-info, apikey, content-type, x-supabase-api-version',
};

function json(body: unknown, status = 200) {
    return new Response(JSON.stringify(body), {
        status,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
}

function extractJson(text: string) {
    const start = text.indexOf('{');
    const end = text.lastIndexOf('}');
    if (start === -1 || end <= start) return null;
    try {
        return JSON.parse(text.slice(start, end + 1));
    } catch {
        return null;
    }
}

async function callGroq(prompt: string): Promise<string | null> {
    const key = Deno.env.get('GROQ_API_KEY');
    if (!key) return null;
    const model = Deno.env.get('GROQ_MODEL') ?? 'openai/gpt-oss-20b';
    try {
        const t0 = Date.now();
        const res = await fetch('https://api.groq.com/openai/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${key}`,
            },
            body: JSON.stringify({
                model,
                messages: [{ role: 'user', content: prompt }],
                temperature: 0.1,
            }),
            signal: AbortSignal.timeout(30000),
        });
        console.log('groq ms', Date.now() - t0, 'status', res.status, 'model', model);
        if (!res.ok) {
            console.error('Groq error', res.status, await res.text());
            return null;
        }
        const data = await res.json();
        return data?.choices?.[0]?.message?.content ?? null;
    } catch (e) {
        console.error('Groq failed', String(e));
        return null;
    }
}

async function callGeminiText(prompt: string): Promise<string | null> {
    const key = Deno.env.get('GEMINI_API_KEY');
    if (!key) return null;
    const model = Deno.env.get('GEMINI_MODEL') ?? 'gemini-3.8-flash';
    try {
        const res = await fetch(
            `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`,
            {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'x-goog-api-key': key },
                body: JSON.stringify({
                    contents: [{ parts: [{ text: prompt }] }],
                    generationConfig: { responseMimeType: 'application/json' },
                }),
                signal: AbortSignal.timeout(30000),
            },
        );
        if (!res.ok) {
            console.error('Gemini error', res.status, await res.text());
            return null;
        }
        const data = await res.json();
        return data?.candidates?.[0]?.content?.parts?.[0]?.text ?? null;
    } catch (e) {
        console.error('Gemini failed', String(e));
        return null;
    }
}

Deno.serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders });
    }

    try {
        const { text, target } = await req.json();
        const src = String(text ?? '').trim().slice(0, 3000);
        if (!src) return json({ error: 'text is required' }, 400);
        const tgt = ['Urdu', 'Sindhi', 'English'].includes(target) ? target : 'Urdu';
        const sindhiRule =
            tgt === 'Sindhi'
                ? '- Write Sindhi in Sindhi Arabic script using Sindhi letters (such as ڄ ڳ ڙ ٻ ڀ ٿ ڻ ڪ), not Urdu words.\n'
                : '';

        const prompt =
            `Translate the text below into ${tgt}.
Rules:
- Keep the legal meaning exactly. Do not add, remove, explain or summarise anything.
- Keep names, numbers, dates, amounts, section numbers and citations unchanged.
- Keep the same paragraph and numbering structure.
- Use simple words an ordinary person can understand.
${sindhiRule}Reply with JSON only, in this shape: {"translation": "<the translated text>"}
TEXT:
${src}`;

        const out = (await callGroq(prompt)) ?? (await callGeminiText(prompt));
        if (!out) return json({ error: 'AI service unavailable' }, 502);

        const parsed = extractJson(out) as { translation?: string } | null;
        let translation = parsed?.translation ? String(parsed.translation) : '';
        if (!translation && !out.includes('{')) translation = out.trim();
        if (!translation) return json({ error: 'Could not translate' }, 502);

        return json({ translation });
    } catch (e) {
        console.error(e);
        return json({ error: 'Bad request' }, 400);
    }
});